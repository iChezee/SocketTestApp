import Database
import NetworkLayer

extension Provider {
    static func create(with mapping: MappingDTO) -> Provider {
        Provider(name: mapping.name, symbol: mapping.symbol)
    }
}
