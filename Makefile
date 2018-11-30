# Makefile to build Nextcloud client under Debian 9 Stretch

VERSION = 2.3.3

# adapted from https://gitlab.com/packaging/nextcloud-client/

default:
	export DEBIAN_FRONTEND=noninteractive
	apt-get update
	apt-get -y -qq install --no-install-recommends \
		apt-utils \
		build-essential \
		ca-certificates \
		checkinstall \
		cmake \
		curl \
		dirmngr \
		doxygen \
		extra-cmake-modules \
		git-core \
		gpg \
		kio-dev \
		libqt5webkit5-dev \
		libsqlite3-dev \
		libssl-dev \
		pkg-config \
		qt5-default \
		qt5keychain-dev \
		qtkeychain-dev \
		qttools5-dev-tools
	apt-get clean
	git clone -b v$(VERSION) https://github.com/nextcloud/client_theming
	cd client_theming && git submodule update --init --recursive
	cd client_theming && mkdir build-linux
	export CMAKE_INSTALL_DIR="/usr"
	cd client_theming/build-linux/ && \
		cmake -DCMAKE_INSTALL_PREFIX=/usr -D OEM_THEME_DIR=`pwd`/../nextcloudtheme ../client
	cd client_theming/build-linux/ && \
		sed -i 's/Icon=nextcloud/Icon=Nextcloud/g' src/gui/nextcloud.desktop && \
		sed -i 's/Icon\[\(.*\)\]=nextcloud/Icon\[\1\]=Nextcloud/g' src/gui/nextcloud.desktop && \
		echo 'Nexcloud desktop synchronization client' > description-pak
	cd client_theming/build-linux/ && \
		checkinstall -y -D \
			--install=no \
			--maintainer='m4lvin packaging \<m4lvin-packaging@w4eg.eu\>' \
			--pkgname="nextcloud-client" \
			--pkgversion=$(VERSION)-m4lvin \
			--arch="amd64" \
			--pkgrelease="`date +%Y%m%d%H%M`" \
			--pkglicense="MIT" \
			--pkgsource="https://github.com/nextcloud/client_theming" \
			--provides="nextcloud-client" \
			--requires="libqt5keychain0\|libqt5keychain1,libqt5webkit5,libqt5xml5,libqt5concurrent5" \
			--exclude='/home' \
			make install
	sha256sum client_theming/build-linux/nextcloud-client*.deb
	cp -v client_theming/build-linux/nextcloud-client*.deb upload/
	cd upload/ && dpkg-scanpackages -m . > Packages
	cd upload/ && gzip -c Packages > Packages.gz
	cd upload/ && apt-ftparchive release . > Release
	cd upload/ && gzip -c Release > Release.gz
	@echo $(PGPWRAPPER) | gpg --batch --passphrase-fd 0 -d m4lvin-packaging-B2CF44CE.asc.gpg > m4lvin-packaging-B2CF44CE.asc
	@gpg --import m4lvin-packaging-B2CF44CE.asc && rm m4lvin-packaging-B2CF44CE.asc
	@cd upload/ && echo $(PGPPHRASE) | gpg --batch --passphrase-fd 0 --armor --sign --detach-sign --local-user 7E420D98B2CF44CE -o Release.gpg Release
