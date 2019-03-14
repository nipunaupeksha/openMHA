% This file is part of the HörTech Open Master Hearing Aid (openMHA);
% Copyright © 2019 HörTech gGmbH;

% openMHA is free software: you can redistribute it and/or modify;
% it under the terms of the GNU Affero General Public License as published by;
% the Free Software Foundation, version 3 of the License.;
%;
% openMHA is distributed in the hope that it will be useful,;
% but WITHOUT ANY WARRANTY; without even the implied warranty of;
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the;
% GNU Affero General Public License, version 3 for more details.;
%;
% You should have received a copy of the GNU Affero General Public License, ;
% version 3 along with openMHA.  If not, see <http://www.gnu.org/licenses/>.;

% Test dc plugin: Effect of time constants in time domain
function test_dc_wave_timeconstants();
  mha = prepare_mha_with_time_constants(0,0,0.005);

  % check that signal processing is identity for input level 65  
  assert_difference_below(amplitude(65), process(mha, 65), 1e-6);

  % check rmslevel stepdown response:
  % 5 milliseconds is 80 samples or 5 blocks
  all_output = [];
  for i = 1:5
    output_signal = process(mha,0);
    all_output = [all_output, output_signal];
  end
  output_signal = output_signal(end);
  %plot(all_output)
  % We expect the level estimate to be at 65dB/exp(1), and therefore
  % expect the gain to be 65dB - 65dB/exp(1) = 65*(1-exp(-1)).
  % applied to an input of 0dB, the gain would also be the output level:
  %assert_difference_below(mean(amplitude(65*(1-exp(-1)))), output_signal, 1e-6);
end

function mha=prepare_mha_with_time_constants(tau_attack, tau_decay, tau_rmslev)
  % basic mha config for 1 channel broadband dc;
  desc.instance = sprintf('test_dc_wave_timeconstants_%f_%f_%f', ...
                          tau_attack, tau_decay, tau_rmslev);
  desc.nchannels_in = 1;
  desc.fragsize = 16;
  desc.srate = 16000;
  desc.mhalib = 'dc';
  desc.iolib = 'MHAIOParser';

  desc.mha.gtmin=[0];
  desc.mha.gtstep=[1];
  desc.mha.gtdata = [[65:-1:-35]]; % constant output level 65 db
  desc.mha.tau_attack = tau_attack;
  desc.mha.tau_decay = tau_decay;
  desc.mha.tau_rmslev = tau_rmslev;

  % start processing, quit;
  mha = mha_start;
  mha_set(mha,'',desc);
  % ensure MHA is terminated after the test;
  unittest_teardown(@mha_set, mha, 'cmd', 'quit');

  mha_set(mha,'cmd','start');

  input_signal = amplitude(65);
  output_signal = [1,2,3,4,5,6,7,8];
  all_output = [];
  while output_signal(1) ~= output_signal(end)
    mha_set(mha,'io.input',input_signal);
    output_signal = mha_get(mha, 'io.output');
    all_output = [all_output; output_signal];
  end
  %plot(all_output(1:100));
end

function output_signal = process(mha, dB)
  mha_set(mha, 'io.input', amplitude(dB));
  output_signal = mha_get(mha, 'io.output');
end

function input_signal = amplitude(dB)
  pascal = 10.^(dB/20) / 5e4;
  input_signal = ones(1,16) * pascal;
end


% Local Variables:;
% mode: octave;
% coding: utf-8-unix;
% indent-tabs-mode: nil;
% End:;