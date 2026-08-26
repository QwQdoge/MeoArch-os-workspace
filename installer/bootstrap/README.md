# ISO Meo keyring bootstrap payload

The protected ISO release workflow stages the reviewed public files
`meo.gpg`, `meo-trusted`, and `meo-revoked` here from the corresponding
Meo keyring release input. They are public trust roots, never private keys.

`configure-meo-repository.sh` fails closed if they are absent. Development
builds may stage this directory without the files, but a real installation must
not proceed until protected release automation supplies them.
