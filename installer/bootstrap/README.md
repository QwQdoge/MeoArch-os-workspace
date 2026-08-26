# ISO Meo keyring bootstrap payload

The protected ISO release workflow stages the reviewed public files
`meo.gpg`, `meo-trusted`, `meo-revoked`, and versioned `meo-keyring.json` here
from the corresponding Meo keyring release input. They are public trust roots,
never private keys. The metadata binds the public payload hashes and reviewed
fingerprints; a signing fingerprint may not be listed in `meo-revoked`.

`configure-meo-repository.sh` fails closed if they are absent. Development
builds may stage this directory without the files, but a real installation must
not proceed until protected release automation supplies them. The payload must
be byte-for-byte identical to `meo-keyring`'s package input.
