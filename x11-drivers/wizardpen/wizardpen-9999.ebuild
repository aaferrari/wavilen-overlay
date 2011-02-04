# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit linux-mod eutils bzr

EBZR_REPO_URI="https://code.launchpad.net/~wizardpen-devs/wizardpen/trunk"

DESCRIPTION="Driver for Genius Wizardpen Tablets"
HOMEPAGE="https://launchpad.net/wizardpen"
SRC_URI=""

DEPEND=""
RDEPEND="x11-base/xorg-server"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""

RDEPEND="${DEPEND}"

src_unpack() {
	if kernel_is 2 4; then
		die "You must use 2.6.X kernel with ${PN}"
	fi
	if ! linux_chkconfig_module INPUT_EVDEV
	then
		if ! linux_chkconfig_present INPUT_EVDEV
			then
			eerror "${PN} requires evdev support for USB tablets"
			eerror "In your .config: CONFIG_INPUT_EVDEV=y or CONFIG_INPUT_EVDEV=m"
			eerror "Through 'make menuconfig':"
						eerror "Device Drivers-> Input device support-> [*] Event interface or"
						eerror "Device Drivers-> Input device support-> [M] Event interface"
						eerror ""
						eerror "If compiled as modules add evdev to /etc/modules.autoload/kernel-2.6"
						die "Please build evdev support first"
		fi
	fi
	if ! linux_chkconfig_present USB_HID
	then
		eerror "${PN} requires USB Human Interface Device support for USB tablets"
		eerror "In your .config: CONFIG_USB_HID=y or CONFIG_USB_HID=m"
		eerror "Through 'make menuconfig':"
		eerror "Device Drivers-> USB support-> [*] USB Human Interface Device (full HID) support or"
		eerror "Device Drivers-> USB support-> [M] USB Human Interface Device (full HID) support"
		eerror ""
		eerror "If compiled as modules add usbhid to /etc/modules.autoload/kernel-2.6"
		die "Please build USB HID support first"
	fi
	bzr_fetch || die "${EBZR}: unknown problem in bzr_fetch()."
	cd ${S}
}

src_compile() {
	(./autogen.sh) || die "autogen.sh failed"
	econf || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	exeinto /usr/lib/xorg/modules/drivers/
	doexe src/.libs/wizardpen_drv.so

	exeinto /usr/bin
	doexe calibrate/wizardpen-calibrate

	dodoc README-XOrgConfig INSTALL
	newdoc calibrate/readme README.calibrate
	newdoc calibrate/ChangeLog ChangeLog.calibrate

	doman man/wizardpen.4

	insinto /etc/hal/fdi/policy
	newins ${FILESDIR}/wizardpen.fdi 45-wizardpen.fdi
}

pkg_postinst() {
	einfo ""
	einfo "You can set tablet working area useing wizardpen-calibrate tool, see"
	einfo "README and INSTALL files from /usr/share/doc/${P} for more details."
	einfo ""
}
