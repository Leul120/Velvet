# SMS gateway setup

OTP, panic, and waitlist invites use `SmsGateway`.

## Local

```
SMS_PROVIDER=log
```

Messages appear in API logs + notification outbox.

## Production (Ethio Telecom / aggregator)

```
SMS_PROVIDER=http
SMS_HTTP_URL=https://your-aggregator/send
SMS_API_KEY=…
SMS_SENDER_ID=VELVET
```

`HttpSmsGateway` posts:

```json
{ "to": "+2519…", "from": "VELVET", "message": "…" }
```

Expect `{ "id" }` or `{ "messageId" }` in the response.

Concierge panic SMS recipients: `CONCIERGE_SMS_PHONES=+2519…,+2519…`
(On-call staff shifts override this list when present.)
