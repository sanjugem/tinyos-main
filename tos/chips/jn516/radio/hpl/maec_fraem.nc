
uint8           u8PayloadLength;
uint8           u8SequenceNum;
uint16          u16FCF;
uint16          u16DestPAN;
uint16          u16SrcPAN;
tuAddr          uDestAddr;
tuAddr          uSrcAddr;
uint16          u16FCS;
uint16          u16Unused;


    union
    {
        uint8     au8Byte[127]; /* Payload as both bytes and words */
        uint32    au32Word[32];
    } uPayload;
