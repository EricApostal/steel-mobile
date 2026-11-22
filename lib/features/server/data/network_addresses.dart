import 'dart:io';

/// An IPv4 address this device can be reached on.
class NetworkAddress {
  const NetworkAddress({required this.interfaceName, required this.ip});

  final String interfaceName;
  final String ip;

  /// Friendly name for the Android interface (`wlan0` → Wi-Fi, ...).
  String get label {
    final n = interfaceName.toLowerCase();
    if (n.startsWith('wlan') || n.startsWith('wifi')) return 'Wi-Fi';
    if (n.startsWith('en')) return 'LAN'; // macOS: Wi-Fi and Ethernet are both enN
    if (n.startsWith('ap') || n.startsWith('swlan')) return 'Hotspot';
    if (n.startsWith('rmnet') || n.startsWith('ccmni') || n.startsWith('v4-')) return 'Mobile data';
    if (n.startsWith('tun') || n.startsWith('utun') || n.startsWith('ppp') || n.startsWith('tailscale')) {
      return 'VPN';
    }
    if (n.startsWith('eth')) return 'Ethernet';
    return interfaceName;
  }

  /// Lower sorts first: addresses other devices on the LAN can actually use.
  int get priority {
    return switch (label) {
      'Wi-Fi' => 0,
      'Ethernet' => 1,
      'Hotspot' => 2,
      'VPN' => 3,
      _ => 4,
    };
  }
}

/// Interfaces that exist but nobody can connect through (macOS AirDrop etc.).
const _ignored = ['awdl', 'llw', 'anpi', 'gif', 'stf', 'bridge'];

/// Non-loopback, non-link-local IPv4 addresses, best candidate first.
Future<List<NetworkAddress>> loadNetworkAddresses() async {
  final interfaces = await NetworkInterface.list(
    type: InternetAddressType.IPv4,
    includeLoopback: false,
    includeLinkLocal: false,
  );
  final addresses = [
    for (final i in interfaces)
      if (!_ignored.any(i.name.toLowerCase().startsWith))
        for (final a in i.addresses) NetworkAddress(interfaceName: i.name, ip: a.address),
  ]..sort((a, b) => a.priority.compareTo(b.priority));
  return addresses;
}
