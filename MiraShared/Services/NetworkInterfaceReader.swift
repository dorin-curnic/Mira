import Foundation
import Darwin

enum NetworkInterfaceReader {
	static func readSnapshot() -> NetworkUsageSnapshot {
		var addresses: UnsafeMutablePointer<ifaddrs>?

		var downloaded: UInt64 = 0
		var uploaded: UInt64 = 0

		guard getifaddrs(&addresses) == 0, let firstAddress = addresses else {
			return NetworkUsageSnapshot(
				timestamp: Date(),
				downloadedBytes: 0,
				uploadedBytes: 0
			)
		}

		defer {
			freeifaddrs(addresses)
		}

		var pointer: UnsafeMutablePointer<ifaddrs>? = firstAddress

		while pointer != nil {
			guard let interface = pointer?.pointee else {
				pointer = pointer?.pointee.ifa_next
				continue
			}

			let name = String(cString: interface.ifa_name)
			let isLoopback = name == "lo0"
			let isInterfaceUp = (interface.ifa_flags & UInt32(IFF_UP)) != 0
			let isLinkLayer = interface.ifa_addr.pointee.sa_family == UInt8(AF_LINK)

			if !isLoopback, isInterfaceUp, isLinkLayer {
				let data = unsafeBitCast(
					interface.ifa_data,
					to: UnsafeMutablePointer<if_data>?.self
				)

				if let data {
					downloaded += UInt64(data.pointee.ifi_ibytes)
					uploaded += UInt64(data.pointee.ifi_obytes)
				}
			}

			pointer = interface.ifa_next
		}

		return NetworkUsageSnapshot(
			timestamp: Date(),
			downloadedBytes: downloaded,
			uploadedBytes: uploaded
		)
	}
}
