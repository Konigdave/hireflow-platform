# Decision 002 - File Upload Strategy

## Initial Decision

The MVP will upload files through the Django API.

## Reason

Keeps the first version simple and allows us to validate the business workflow before introducing direct browser uploads.

## Future Improvement

Migrate to Amazon S3 pre-signed URLs.

## Benefits

- Reduced application bandwidth
- Better scalability
- Time-limited upload permissions
- Reduced load on API servers
