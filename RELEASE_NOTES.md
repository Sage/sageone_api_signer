# v1.4.0
* Change how spaces in query parameters are handled in v3 to percent encode as %20

# v1.3.0
* Rename to `sageone_api_signer`

# v1.2.0
* Add missing request headers. The `request_headers` method now requires your application name as a parameter. For example: `@signer.request_headers("NPSS")`
* Add Travis CI
