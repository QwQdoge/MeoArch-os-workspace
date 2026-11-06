> 📚 [MeoArch 主文档 / Master Doc](https://github.com/QwQdoge/MeoArch-os-workspace/blob/main/docs/MEOARCH_MASTER.md)：全部仓库地图、操作手册、Cloudflare 清单、全部文档链接。<!-- meoarch-master -->

# ISO Meo keyring bootstrap payload

The protected ISO release workflow stages the reviewed public files
`meo.gpg`, `meo-trusted`, and `meo-revoked` here from the corresponding
Meo keyring release input. They are public trust roots, never private keys.

`configure-meo-repository.sh` fails closed if they are absent. Development
builds may stage this directory without the files, but a real installation must
not proceed until protected release automation supplies them.
