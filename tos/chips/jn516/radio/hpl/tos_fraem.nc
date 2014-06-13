
  nxle_uint8_t length;
  nxle_uint16_t fcf;
  nxle_uint8_t dsn;
  nxle_uint16_t destpan;
  nxle_uint16_t dest;
  nxle_uint16_t src;
#ifndef TFRAMES_ENABLED
  nxle_uint8_t network; /** I-Frame 6LowPAN interoperability byte */
#endif
  nxle_uint8_t type;
