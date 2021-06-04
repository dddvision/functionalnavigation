# Copyright 2011 Scientific Systems Company Inc., New BSD License

from abc import abstractmethod, ABCMeta

class Trajectory(object):
    __metaclass__ = ABCMeta

    @abstractmethod
    def domain(self):
        pass

    @abstractmethod
    def evaluate(self, time_list, pose_list):
        pass

    @abstractmethod
    def tangent(self, time_list, tangentpose_list):
        pass

