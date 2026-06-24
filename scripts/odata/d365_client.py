"""
D365 Finance & Operations OData client.
Handles Azure AD (MSAL) client-credentials authentication and provides
a thin wrapper over the OData v4 REST endpoints exposed by D365 F&O.
"""

from __future__ import annotations

import os
from typing import Any, Iterable

import msal
import requests
from dotenv import load_dotenv

load_dotenv()


class D365AuthError(RuntimeError):
    """Raised when token acquisition fails."""


class D365Client:
    """Minimal OData client for D365 Finance & Operations."""

    def __init__(
        self,
        tenant_id: str | None = None,
        client_id: str | None = None,
        client_secret: str | None = None,
        env_url: str | None = None,
    ) -> None:
        self.tenant_id = tenant_id or os.environ["D365_TENANT_ID"]
        self.client_id = client_id or os.environ["D365_CLIENT_ID"]
        self.client_secret = client_secret or os.environ["D365_CLIENT_SECRET"]
        self.env_url = (env_url or os.environ["D365_ENV_URL"]).rstrip("/")
        self._token: str | None = None

    def _get_token(self) -> str:
        if self._token:
            return self._token
        authority = f"https://login.microsoftonline.com/{self.tenant_id}"
        app = msal.ConfidentialClientApplication(
            client_id=self.client_id,
            client_credential=self.client_secret,
            authority=authority,
        )
        scope = [f"{self.env_url}/.default"]
        result = app.acquire_token_for_client(scopes=scope)
        if "access_token" not in result:
            raise D365AuthError(
                f"Token acquisition failed: {result.get('error')} - "
                f"{result.get('error_description')}"
            )
        self._token = result["access_token"]
        return self._token

    def _headers(self) -> dict[str, str]:
        return {
            "Authorization": f"Bearer {self._get_token()}",
            "Accept": "application/json",
            "OData-MaxVersion": "4.0",
            "OData-Version": "4.0",
        }

    def get_entity(
        self,
        entity_name: str,
        select: Iterable[str] | None = None,
        filter: str | None = None,
        expand: str | None = None,
        top: int | None = None,
        cross_company: bool = False,
    ) -> list[dict[str, Any]]:
        url = f"{self.env_url}/data/{entity_name}"
        params: dict[str, Any] = {}
        if select:
            params["$select"] = ",".join(select)
        if filter:
            params["$filter"] = filter
        if expand:
            params["$expand"] = expand
        if top:
            params["$top"] = top
        if cross_company:
            params["cross-company"] = "true"
        records: list[dict[str, Any]] = []
        while url:
            response = requests.get(url, headers=self._headers(), params=params, timeout=60)
            response.raise_for_status()
            payload = response.json()
            records.extend(payload.get("value", []))
            url = payload.get("@odata.nextLink")
            params = {}
        return records

    def get_entity_count(self, entity_name: str, filter: str | None = None) -> int:
        url = f"{self.env_url}/data/{entity_name}/$count"
        params = {"$filter": filter} if filter else {}
        response = requests.get(url, headers=self._headers(), params=params, timeout=60)
        response.raise_for_status()
        return int(response.text)

    def create_entity(self, entity_name: str, payload: dict[str, Any]) -> dict[str, Any]:
        url = f"{self.env_url}/data/{entity_name}"
        headers = {**self._headers(), "Content-Type": "application/json"}
        response = requests.post(url, headers=headers, json=payload, timeout=60)
        response.raise_for_status()
        return response.json()

    def update_entity(self, entity_name: str, key: str, payload: dict[str, Any]) -> None:
        url = f"{self.env_url}/data/{entity_name}{key}"
        headers = {**self._headers(), "Content-Type": "application/json"}
        response = requests.patch(url, headers=headers, json=payload, timeout=60)
        response.raise_for_status()
