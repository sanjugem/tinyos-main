
/* Wrapper config for interfaces that operate on the metadata level of a packet.
 * This is designed for BLIP, and any radio that wishes to support BLIP needs
 * to create this configuration and provide these interfaces.
 *
 * @author Brad Campbell <bradjc@umich.edu>
 */

configuration RadioPacketMetadataC {
  provides {
    interface LowPowerListening;
    interface PacketLink;
    interface PacketAcknowledgements;
  }
}

implementation {
  components Jn516RadioC;

  LowPowerListening = Jn516RadioC.LowPowerListening;
  PacketLink = Jn516RadioC.PacketLink;
  PacketAcknowledgements = Jn516RadioC.PacketAcknowledgements;
}
