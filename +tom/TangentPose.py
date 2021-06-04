# Copyright 2011 Scientific Systems Company Inc., New BSD License

import Pose

class TangentPose(Pose.Pose):

    def __init__(self):

        self.r = [float('nan')]*3
        self.s = [float('nan')]*3

