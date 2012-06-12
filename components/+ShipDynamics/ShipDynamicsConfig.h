#ifndef SHIPDYNAMICSCONFIG_H_
#define SHIPDYNAMICSCONFIG_

namespace ShipDynamics
{
  const double ShipDynamics::rate = 30.0; // first-order integration can become unstable if the rate is too slow
  const double ShipDynamics::radius = 0.6; // derived from Kingfisher specs
  const double ShipDynamics::normalizedMass = 0.6; // roughly mass*(2/maxThrust)
  const double ShipDynamics::damping = 2.0/1.3/1.3; // derived from Kingfisher specs (2/maxSpeed^2)
  const double ShipDynamics::rotationalDamping = 2.0*0.6/0.3/0.3; // assumed (2*radius/maxHeadingRate^2)
}

#endif
