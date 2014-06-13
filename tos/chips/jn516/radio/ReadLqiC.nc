
/*
 * Different platforms have different ways of getting in touch with
 * the LQI reading the radio provides.  This module wraps the
 * different ways in platform-independent logic.
 *
 *
 * @author Stephen Dawson-Haggerty <stevedh@eecs.berkeley.edu>
 */

configuration ReadLqiC {
  provides interface ReadLqi;
} implementation {

  // jn516 platforms
  components Jn516ReadLqiC, Jn516PacketC;
  ReadLqi = Jn516ReadLqiC;
}
