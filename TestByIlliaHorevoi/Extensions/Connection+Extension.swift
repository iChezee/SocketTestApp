import NetworkLayer
import Database

extension Connection {
    init(instrument: Instrument) {
        let provider = instrument.providers.first(where: { $0.name == "simulation" })?.name ?? instrument.providers.first?.name ?? ""
        self.init(instrumentID: instrument.id, provider: provider, isSubscribed: true)
    }
}
