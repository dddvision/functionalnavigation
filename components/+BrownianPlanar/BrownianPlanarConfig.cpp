namespace BrownianPlanar
{
  const double BrownianPlanar::rate = 5.0; // strictly positive
  const double BrownianPlanar::initialPosition[3] = {6378137.0, 0.0, 0.0}; // initial position in ECEF
  const double BrownianPlanar::initialQuaternion[4] = {1.0, 0.0, 0.0, 0.0}; // unit magnitude to machine precision
  const double BrownianPlanar::normalizedMass = 0.5; // strictly positive
  const double BrownianPlanar::normalizedRotationalMass = 100.0; // strictly positive
}
