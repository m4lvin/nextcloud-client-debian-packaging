# Makefile to build Nextcloud client under Debian 9 Stretch

VERSION = 2.5.0

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
		libqt5svg5-dev \
		libqt5webkit5-dev \
		libsqlite3-dev \
		libssl-dev \
		libzip-dev \
		pkg-config \
		qt5-default \
		qt5keychain-dev \
		qtdeclarative5-dev \
		qtkeychain-dev \
		qttools5-dev-tools \
		qtwebengine5-dev \
		sqlite3 \
		wget
	apt-get clean
	wget https://github.com/nextcloud/desktop/archive/v$(VERSION).tar.gz
	tar xvf v$(VERSION).tar.gz
	mkdir desktop-$(VERSION)/build
	export CMAKE_INSTALL_DIR="/usr"
	cd desktop-$(VERSION)/build/ && cmake -DCMAKE_INSTALL_PREFIX=/usr ..
	cd desktop-$(VERSION)/build/ && \
		sed -i 's/Icon=nextcloud/Icon=Nextcloud/g' src/gui/nextcloud.desktop && \
		sed -i 's/Icon\[\(.*\)\]=nextcloud/Icon\[\1\]=Nextcloud/g' src/gui/nextcloud.desktop && \
		echo 'Nextcloud desktop synchronization client' > description-pak
	cd desktop-$(VERSION)/build/ && \
		checkinstall -y -D \
			--install=no \
			--maintainer='m4lvin packaging \<m4lvin-packaging@w4eg.eu\>' \
			--pkgname="nextcloud-client" \
			--pkgversion=$(VERSION)-m4lvin \
			--arch="amd64" \
			--pkgrelease="`date +%Y%m%d%H%M`" \
			--pkglicense="MIT" \
			--pkgsource="https://github.com/nextcloud/desktop" \
			--provides="nextcloud-client" \
			--requires="libqt5keychain0\|libqt5keychain1,libqt5webkit5,libqt5xml5,libqt5concurrent5,libqt5webenginewidgets5" \
			--exclude='/home' \
			make install
	sha256sum desktop-$(VERSION)/build/nextcloud-client*.deb
	cp -v desktop-$(VERSION)/build/nextcloud-client*.deb upload/
	cd upload/ && dpkg-scanpackages -m . > Packages
	cd upload/ && gzip -c Packages > Packages.gz
	cd upload/ && apt-ftparchive release . > Release
	cd upload/ && gzip -c Release > Release.gz
	@echo $(PGPWRAPPER) | gpg --batch --passphrase-fd 0 -d m4lvin-packaging-B2CF44CE.asc.gpg > m4lvin-packaging-B2CF44CE.asc
	@gpg --import m4lvin-packaging-B2CF44CE.asc && rm m4lvin-packaging-B2CF44CE.asc
	@cd upload/ && echo $(PGPPHRASE) | gpg --batch --passphrase-fd 0 --armor --sign --detach-sign --local-user 7E420D98B2CF44CE -o Release.gpg Release
