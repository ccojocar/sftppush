module github.com/olmax99/sftppush

require (
	github.com/aws/aws-sdk-go v1.34.33
	github.com/fsnotify/fsnotify v1.4.7
	github.com/inconshreveable/mousetrap v1.0.0 // indirect
	github.com/pkg/errors v0.9.1
	github.com/sirupsen/logrus v1.4.1
	github.com/spf13/afero v1.1.2
	github.com/spf13/cobra v0.0.3
	github.com/spf13/viper v1.3.2
	golang.org/x/tools/gopls v0.4.4 // indirect
)

go 1.13

replace github.com/fsnotify/fsnotify v1.4.7 => github.com/olmax99/fsnotify v1.5.0
