## Helmez
Under active development, contributions are appreciated, Apis may brake between versions;

Helmez is a helm plugin which helps to manage the big values file to multiple files, It usefull especially when you have to configure the requirements configurations in a big helm chart.

### Usage
Inorder to use the plugin
run following.
```
helm plugin install \<helmplugin link\>
eg: run folloing to add this plugin on linux amd64 arch system 

helm plugin install https://github.com/ysaakpr/helmez-bin/releases/download/0.1.3/helmez.linux.amd64.tgz
```

Helmez (helmeezi) depends on the directory structure inorder to build the final values file. the suggested directory structure is as follwos.

```
values/
     appOne/
        values.yaml
        properties.conf
        .ignored
    appTwo/
        values.yaml
        logger.xml
    values.yaml
    helmez.yaml
```

The generated values file will be like following.
```
//Contents from root values.yaml
gloobal:
   test: true


appTwo:
    #App two peoperties and extra files will be added here

appOne:
    #Here goes all contest of appOne values.yaml
    app: AppOne
    #If there any extra files are there, which will be added to  some paths in the appOne
    config:
        files:
            properties.conf : |+
                #contents of properties.conf in appOne folder will be added here, the path on which the extra files to be added can be configured using extra_files_root properties in the helmez.yaml
