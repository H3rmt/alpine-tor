# CHANGELOG

<!--- next entry here -->

## 0.0.1
2020-09-02

### Fixes

- README.md (fbeedb3047047aa0059def66c2a5c0fb336f5d4c)
- tor is build from src (a2307ee75d250720956fced7b8903fa7079e594c)
- naming (2c655a027f112d906b8ddf35a436489e374e1fdc)
- fixed README.md (e81e91fff2dfab97cfeb5149858a8e2dfa2df700)
- README.md (beb233d52a036a179914d35c62e42a3477c94691)
- Added alpine-tor-deployment.yaml for kubernetes deployment (cb0fe39643104f926b584c14fb77bbdca0baae31)
- Added entrypoint.sh which sets required values in torrc dependent on the environment variable "mode". Added related deployment yamls for each mode (2aaf35e16fd590a6e1d633f0e5573deb633658e4)
- updated README.md (6c44a200a4f139bda02dea3de21dfead8b19d650)
- fixed deployment env variables (5c3b2b56938cfa923077f3a27a1cb8beb67bc0f4)
- initial commit helm chart and configurable ports (b5e568f0a8500ac967328607a8c25614eb8f98ae)
- general overhaul deployments and chart (101ac5720ff06149d5f67a835dfd77881ea7e0fc)
- name indicator (f9c3789415fea27e633559356278813b0899c192)
- default nickname (3f60c14a097eeecd091ac93f260d2ce55a7d9a1e)
- seperate user is used for running tor. Fixed encoding for entrypoint.sh (5562616e88a7896391bf9fb2578a04fc4a2d6fe3)
- homedirectory is owned by toruser (825ec10b98508fafdf25d61c592b9a81292a5623)
- creating .tor directory and chown toruser (9f554414b531fda452512214b21b16dadd0b310a)
- going back too root user (266e983ad4238e7bf721591f21b8203fb53834f3)
- Re-Added toruser and added datadir /tor (fb4050fc9f4f1641267c86c5d93b3b381505901e)
- creation of /tor folder (0f1c700ffdb13a9051b8cffba80738abf3f86211)
- removed toruser (32749370b7bbac9bd2b285e8716e8b3644a09ca0)
-  (dfa1d8c50ef20d66d807b8fa1bbbb9025b755313)
- Added support for setting dnsport,dnslistenaddress,myfamily,hiddenservicedir,hiddenserviceport within torrc (1a5de9ee27a28f46fd1297c66d8223613f3dbb18)
- initial commit gitlab.ci (8eca51ff6213b154f6b525e42cdce6e7626bd790)
- initial commit gitlab-ci (9a50bccced7a744c51be7008194bba2e73233c6c)