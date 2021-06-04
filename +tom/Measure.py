# Copyright 2011 Scientific Systems Company Inc., New BSD License

import Sensor, Trajectory

from abc import abstractmethod, ABCMeta

class Measure(Sensor.Sensor):

    staticDescriptionList = {}
    
    @staticmethod
    def pDescriptionList():
        return Measure.staticDescriptionList

    staticFactoryList = {}

    @staticmethod
    def pFactoryList():
        return Measure.staticFactoryList

    def __init__(self, initialTime, uri):
        Sensor.__init__(initialTime)

    @staticmethod
    def connect(name, cD, cF):
        Measure.pDescriptionList()[name] = cD
        Measure.pFactoryList()[name] = cF

    @staticmethod
    def isConnected(name):
        return Measure.pFactoryList().has_key(name)
    
    @staticmethod
    def description(name):
        return Measure.pDescriptionList().get(name)

    @staticmethod
    def create(name, initialTime, uri):
        if Measure.isConnected(name):
            return Measure.pFactoryList().get(name)(initialTime, uri)
        else:
            raise ValueError('Measure is not connected to the requested component')

    @staticmethod
    def initialize(name):
        pass

    @abstractmethod
    def findEdges(self, naMin, naMax, nbMin, nbMax, edgeList):
        pass

    @abstractmethod
    def computeEdgeCost(self, traj_x, graphEdge):
        pass
