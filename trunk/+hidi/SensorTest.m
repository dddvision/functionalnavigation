classdef SensorTest

  methods (Access = public, Static = true)
    function this = SensorTest(sensor)
      fprintf('\n\n*** Begin Sensor Test ***\n');
      assert(isa(sensor, 'hidi.Sensor'));
      
      fprintf('\nhasData =');
      flag = sensor.hasData();
      assert(isa(flag, 'logical'));
      if(flag)
        fprintf(' true');

        fprintf('\nfirst =');
        first = sensor.first();
        assert(isa(first, 'uint32'));
        fprintf(' %d', first);

        fprintf('\nlast =');
        last = sensor.last();
        assert(isa(last, 'uint32'));
        fprintf(' %d', last);

        fprintf('\ngetTime(%d) =', uint32(first));
        ta = sensor.getTime(first);
        assert(isa(ta, 'double'));
        fprintf(' %f', double(ta));

        fprintf('\ngetTime(%d) =', uint32(last));
        tb = sensor.getTime(last);
        assert(isa(tb, 'double'));
        fprintf(' %f', double(tb));

        if(last>first)
          fprintf('\nsecondsPerNode = %f', (tb-ta)/double(last-first));
        end
      else
        fprintf(' false');
      end
    
      fprintf('\n\n*** End Sensor Test ***');
    end
  end
  
end
