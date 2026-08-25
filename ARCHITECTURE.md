# TaskFlow architecture

```
Presentation (screens + Riverpod auth state)
        ↓
Domain (repository contracts / use cases)
        ↓
Data (repository implementations → mock data source → JSON asset)
        ↓
Secure storage (session tokens + expiry only)
```

`MockDataSource` is the sole reader of the bundled JSON file. Repositories keep a mutable in-memory copy, so mutations behave like API calls while the UI remains independent of where data originates. Replacing the source with HTTP requires no changes to screens.

Authentication stores token strings, expiry, and non-sensitive session email in secure storage. On app startup, an expired access token is refreshed from the mock response. Passwords are never stored.
