dist: | check-style test package

build-linux:
	@echo Build Linux amd64
ifeq ($(BUILDER_GOOS_GOARCH),"linux_amd64")
	env GOOS=linux GOARCH=amd64 $(GO) build -o $(GOBIN) $(GOFLAGS) -trimpath -ldflags '$(LDFLAGS)' ./...
else
	mkdir -p $(GOBIN)/linux_amd64
	env GOOS=linux GOARCH=amd64 $(GO) build -o $(GOBIN)/linux_amd64 $(GOFLAGS) -trimpath -ldflags '$(LDFLAGS)' ./...
endif

build-osx:
	@echo Build OSX amd64
ifeq ($(BUILDER_GOOS_GOARCH),"darwin_amd64")
	env GOOS=darwin GOARCH=amd64 $(GO) build -o $(GOBIN) $(GOFLAGS) -trimpath -ldflags '$(LDFLAGS)' ./...
else
	mkdir -p $(GOBIN)/darwin_amd64
	env GOOS=darwin GOARCH=amd64 $(GO) build -o $(GOBIN)/darwin_amd64 $(GOFLAGS) -trimpath -ldflags '$(LDFLAGS)' ./...
endif
	@echo Build OSX arm64
ifeq ($(BUILDER_GOOS_GOARCH),"darwin_arm64")
	env GOOS=darwin GOARCH=arm64 $(GO) build -o $(GOBIN) $(GOFLAGS) -trimpath -ldflags '$(LDFLAGS)' ./...
else
	mkdir -p $(GOBIN)/darwin_arm64
	env GOOS=darwin GOARCH=arm64 $(GO) build -o $(GOBIN)/darwin_arm64 $(GOFLAGS) -trimpath -ldflags '$(LDFLAGS)' ./...
endif

build-windows:
	@echo Build Windows amd64
ifeq ($(BUILDER_GOOS_GOARCH),"windows_amd64")
	env GOOS=windows GOARCH=amd64 $(GO) build -o $(GOBIN) $(GOFLAGS) -trimpath -ldflags '$(LDFLAGS)' ./...
else
	mkdir -p $(GOBIN)/windows_amd64
	env GOOS=windows GOARCH=amd64 $(GO) build -o $(GOBIN)/windows_amd64 $(GOFLAGS) -trimpath -ldflags '$(LDFLAGS)' ./...
endif

build-cmd-linux:
	@echo Build CMD Linux amd64
ifeq ($(BUILDER_GOOS_GOARCH),"linux_amd64")
	env GOOS=linux GOARCH=amd64 $(GO) build -o $(GOBIN) $(GOFLAGS) -trimpath -ldflags '$(LDFLAGS)' ./cmd/...
else
	mkdir -p $(GOBIN)/linux_amd64
	env GOOS=linux GOARCH=amd64 $(GO) build -o $(GOBIN)/linux_amd64 $(GOFLAGS) -trimpath -ldflags '$(LDFLAGS)' ./cmd/...
endif
	@echo Build CMD Linux arm64
ifeq ($(BUILDER_GOOS_GOARCH),"linux_arm64")
	env GOOS=linux GOARCH=arm64 $(GO) build -o $(GOBIN) $(GOFLAGS) -trimpath -ldflags '$(LDFLAGS)' ./cmd/...
else
	mkdir -p $(GOBIN)/linux_arm64
	env GOOS=linux GOARCH=arm64 $(GO) build -o $(GOBIN)/linux_arm64 $(GOFLAGS) -trimpath -ldflags '$(LDFLAGS)' ./cmd/...
endif

build-cmd-osx:
	@echo Build CMD OSX amd64
ifeq ($(BUILDER_GOOS_GOARCH),"darwin_amd64")
	env GOOS=darwin GOARCH=amd64 $(GO) build -o $(GOBIN) $(GOFLAGS) -trimpath -ldflags '$(LDFLAGS)' ./cmd/...
else
	mkdir -p $(GOBIN)/darwin_amd64
	env GOOS=darwin GOARCH=amd64 $(GO) build -o $(GOBIN)/darwin_amd64 $(GOFLAGS) -trimpath -ldflags '$(LDFLAGS)' ./cmd/...
endif
	@echo Build CMD OSX arm64
ifeq ($(BUILDER_GOOS_GOARCH),"darwin_arm64")
	env GOOS=darwin GOARCH=arm64 $(GO) build -o $(GOBIN) $(GOFLAGS) -trimpath -ldflags '$(LDFLAGS)' ./cmd/...
else
	mkdir -p $(GOBIN)/darwin_arm64
	env GOOS=darwin GOARCH=arm64 $(GO) build -o $(GOBIN)/darwin_arm64 $(GOFLAGS) -trimpath -ldflags '$(LDFLAGS)' ./cmd/...
endif

build-cmd-windows:
	@echo Build CMD Windows amd64
ifeq ($(BUILDER_GOOS_GOARCH),"windows_amd64")
	env GOOS=windows GOARCH=amd64 $(GO) build -o $(GOBIN) $(GOFLAGS) -trimpath -ldflags '$(LDFLAGS)' ./cmd/...
else
	mkdir -p $(GOBIN)/windows_amd64
	env GOOS=windows GOARCH=amd64 $(GO) build -o $(GOBIN)/windows_amd64 $(GOFLAGS) -trimpath -ldflags '$(LDFLAGS)' ./cmd/...
endif

build: build-linux

build-cmd: build-cmd-linux

build-client:
	@echo Building mattermost web app

	cd $(BUILD_WEBAPP_DIR) && $(MAKE) build

package-prep:
	@ echo Packaging mattermost
	@# Remove any old files
	rm -Rf $(DIST_ROOT)

	@# Resource directories
	mkdir -p $(DIST_PATH)/config
	cp -L config/README.md $(DIST_PATH)/config
	OUTPUT_CONFIG=$(PWD)/$(DIST_PATH)/config/config.json go run ./scripts/config_generator
	cp -RL fonts $(DIST_PATH)
	cp -RL templates $(DIST_PATH)
	rm -rf $(DIST_PATH)/templates/*.mjml $(DIST_PATH)/templates/partials/
	cp -RL i18n $(DIST_PATH)

	@# Disable developer settings
	sed -i'' -e 's|"ConsoleLevel": "DEBUG"|"ConsoleLevel": "INFO"|g' $(DIST_PATH)/config/config.json
	sed -i'' -e 's|"SiteURL": "http://localhost:8065"|"SiteURL": ""|g' $(DIST_PATH)/config/config.json

	@# Reset email sending to original configuration
	sed -i'' -e 's|"SendEmailNotifications": true,|"SendEmailNotifications": false,|g' $(DIST_PATH)/config/config.json
	sed -i'' -e 's|"FeedbackEmail": "test@example.com",|"FeedbackEmail": "",|g' $(DIST_PATH)/config/config.json
	sed -i'' -e 's|"ReplyToAddress": "test@example.com",|"ReplyToAddress": "",|g' $(DIST_PATH)/config/config.json
	sed -i'' -e 's|"SMTPServer": "localhost",|"SMTPServer": "",|g' $(DIST_PATH)/config/config.json
	sed -i'' -e 's|"SMTPPort": "2500",|"SMTPPort": "",|g' $(DIST_PATH)/config/config.json
	chmod 600 $(DIST_PATH)/config/config.json

	@# Package webapp
	mkdir -p $(DIST_PATH)/client
	cp -RL $(BUILD_WEBAPP_DIR)/dist/* $(DIST_PATH)/client

	@# Help files
ifeq ($(BUILD_ENTERPRISE_READY),true)
	cp $(BUILD_ENTERPRISE_DIR)/ENTERPRISE-EDITION-LICENSE.txt $(DIST_PATH)
	cp -L $(BUILD_ENTERPRISE_DIR)/cloud/config/cloud_defaults.json $(DIST_PATH)/config
else
	cp build/MIT-COMPILED-LICENSE.md $(DIST_PATH)
endif
	cp NOTICE.txt $(DIST_PATH)
	cp README.md $(DIST_PATH)
	if [ -f ../manifest.txt ]; then \
		cp ../manifest.txt $(DIST_PATH); \
	fi

	@# Import Mattermost plugin public key
	gpg --import build/plugin-production-public-key.gpg

	@# Download prepackaged plugins
	mkdir -p tmpprepackaged
	@cd tmpprepackaged && for plugin_package in $(PLUGIN_PACKAGES) ; do \
		for ARCH in "linux-amd64" ; do \
			curl -f -O -L https://plugins-store.test.mattermost.com/release/$$plugin_package-$$ARCH.tar.gz; \
			curl -f -O -L https://plugins-store.test.mattermost.com/release/$$plugin_package-$$ARCH.tar.gz.sig; \
		done; \
	done

package-general:
	@# Create needed directories
	mkdir -p $(DIST_PATH_GENERIC)/bin
	mkdir -p $(DIST_PATH_GENERIC)/logs
	mkdir -p $(DIST_PATH_GENERIC)/prepackaged_plugins

	@# ----- PLATFORM SPECIFIC -----

	@# Make linux package
	@# Copy binary
ifeq ($(BUILDER_GOOS_GOARCH),"linux_amd64")
	cp $(GOBIN)/mattermost $(DIST_PATH)/bin # from native bin dir, not cross-compiled
else
	cp $(GOBIN)/linux_amd64/mattermost $(DIST_PATH)/bin # from cross-compiled bin dir
endif
	#Download MMCTL for $(MMCTL_PLATFORM)
	scripts/download_mmctl_release.sh "Linux" $(DIST_PATH)/bin
	@# Prepackage plugins
	@for plugin_package in $(PLUGIN_PACKAGES) ; do \
		ARCH="linux-amd64"; \
		cp tmpprepackaged/$$plugin_package-$$ARCH.tar.gz $(DIST_PATH)/prepackaged_plugins; \
		cp tmpprepackaged/$$plugin_package-$$ARCH.tar.gz.sig $(DIST_PATH)/prepackaged_plugins; \
		HAS_ARCH=`tar -tf $(DIST_PATH)/prepackaged_plugins/$$plugin_package-$$ARCH.tar.gz | grep -oE "dist/plugin-.*"`; \
		if [ "$$HAS_ARCH" != "dist/plugin-linux-amd64" ]; then \
			echo "Contains $$HAS_ARCH in $$plugin_package-$$ARCH.tar.gz but needs dist/plugin-linux-amd64"; \
			exit 1; \
		fi; \
		gpg --verify $(DIST_PATH)/prepackaged_plugins/$$plugin_package-$$ARCH.tar.gz.sig $(DIST_PATH)/prepackaged_plugins/$$plugin_package-$$ARCH.tar.gz; \
		if [ $$? -ne 0 ]; then \
			echo "Failed to verify $$plugin_package-$$ARCH.tar.gz|$$plugin_package-$$ARCH.tar.gz.sig"; \
			exit 1; \
		fi; \
	done
	@# Package
	tar -C dist -czf $(DIST_PATH)-$(BUILD_TYPE_NAME)-linux-amd64.tar.gz mattermost
	@# Don't clean up native package so dev machines will have an unzipped package available
	@#rm -f $(DIST_PATH)/bin/mattermost

package: package-osx package-linux package-windows
	rm -rf tmpprepackaged
	rm -rf $(DIST_PATH)
