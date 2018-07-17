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
```


```
GLOBAL OPTIONS:
   --base BASE, -b BASE               Execute in base directory BASE (default: "./")
   --dir DIR, -d DIR                  default folder name DIR, default `values` (default: "values")
   --out values.yaml, -o values.yaml  write the generate yaml to file values.yaml (default: "values.yaml")
   --helmez HELMEZ                    default helmez config file HELMEZ (default: "helmez.yaml")
   --help, -h                         show help
   --version, -v                      print the version

```

helmez.yaml can be used in any sub directory to override the defaults of of each application should be configured
```
values_file_name: "values.yaml" # can use different name for values.yaml

ignore_dot_file: true # by default helmez wont include any file/dir starting with "."

extra_files_to_kv: true # toggle concidering extra files in the dir to the key value pair in the values file

extra_file_root: ["config", "files"] #if extra_files_to_kv is true, extra_file_root sets the root on which the files should be added as key value pair

ignored_files: [] # in case want to ignore few files from the directory to getting added to the generated files


//Config Object
type HelmezConfig struct {
	ValuesFileName string   `yaml:"values_file_name"`
	IgnoreDotFile  bool     `yaml:"ignore_dot_file"`
	ExtraFilesToKV bool     `yaml:"extra_files_to_kv"`
	ExtraFileRoot  []string `yaml:"extra_files_root"`
	IgnoredFiles   []string `yaml:"ignored_files"`
}
```
