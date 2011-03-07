
from abc import abstractmethod, ABCMeta

import WorldTime
import Trajectory

class Sensor(object):
    __metaclass__ = ABCMeta

    @abstractmethod
    def refresh(self, traj):
        pass

    @abstractmethod
    def hasData(self):
        return False

    @abstractmethod
    def first(self):
        raise ValueError

    @abstractmethod
    def last(self):
        raise ValueError

    @abstractmethod
    def getTime(self, n):
        return WorldTime.WorldTime()
    
