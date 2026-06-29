import Darwin
import Foundation

enum NetworkInterfaceReaderError: Error {
	case addressLookupFailed
	case activeInterfaceUnavailable
}

enum NetworkInterfaceReader {
	static func readSnapshot() throws -> NetworkUsageSnapshot {
		var addresses: UnsafeMutablePointer<ifaddrs>?

		var downloaded: UInt64 = 0
		var uploaded: UInt64 = 0
		var hasReadableInterface = false

		guard getifaddrs(&addresses) == 0, let firstAddress = addresses else {
			throw NetworkInterfaceReaderError.addressLookupFailed
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

			defer {
				pointer = interface.ifa_next
			}

			guard let address = interface.ifa_addr else {
				continue
			}

			let name = String(cString: interface.ifa_name)
			let isLoopback = name == "lo0"
			let isInterfaceUp = (interface.ifa_flags & UInt32(IFF_UP)) != 0
			let isLinkLayer = address.pointee.sa_family == UInt8(AF_LINK)

			guard !isLoopback, isInterfaceUp, isLinkLayer else {
				continue
			}

			let data = unsafeBitCast(
				interface.ifa_data,
				to: UnsafeMutablePointer<if_data>?.self
			)

			guard let data else {
				continue
			}

			hasReadableInterface = true
			downloaded += UInt64(data.pointee.ifi_ibytes)
			uploaded += UInt64(data.pointee.ifi_obytes)
		}

		guard hasReadableInterface else {
			throw NetworkInterfaceReaderError.activeInterfaceUnavailable
		}

		return NetworkUsageSnapshot(
			timestamp: Date(),
			downloadedBytes: downloaded,
			uploadedBytes: uploaded
		)
	}
}
