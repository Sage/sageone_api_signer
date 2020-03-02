# v1.next
* Upgrade Rake gem dependency to be at least v12.3.3, mitigating CVE-2020-8130

# v1.3.0
* Rename to `sageone_api_signer`

# v1.2.0
* Add missing request headers. The `request_headers` method now requires your application name as a parameter. For example: `@signer.request_headers("NPSS")`
* Add Travis CI
