function args = CSCinput()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CSCinput.m  Function to provide parameters to CSC
%
% Parameter description:
% datafolder: directory containing all data (input/output) files
%
% inroot: input particle field filename root string (i.e. filename string
%         that precedes file number)
%
% outroot: output coloring field filename root string 
%
% first: first particle field file number
%
% last: last particle field file number
%
% increment: integer increment between particle field numbers to be
%            used for analysis
%
% numformat: file number format; e.g. inroot_001 is '%03d' format, 
%            blankingroot_00001 is '%05d' format 
%
% fileextension: file extension
%
% separator: character separating columns in data files; use '\t' to 
%            specify tab separator, use '' to specify single space
%            separator
%
% numheaderlines: number of header lines in particle field data files
%
% 
% lengthcalib_axis: meters per unit of length for particle field axes 
%                   (e.g. 1/1000 if particle field axes are in mm)
% 
% numparticlefields: number of preceding particle fields to include in
%                    calculation of coloring field; number of particle 
%                    fields will be limited by availability of preceding 
%                    particle fields
%
% export_first: fisrt frame for which to export CSC field
%
% export_last: last frame for which to export CSC field
%
% export_increment: increment between exported fields
%
% xoutnodes/youtnodes/zoutnodes: number of nodes in Cartesian grid used
%                                for plotting the output color field
% 
% plot_delay: time delay (in seconds) between the display of successive 
%             particle position and color fields for time series data sets
%
% export_data: set to 1 to save coloring data to file 
%
% export_format: set to 'ascii' to save an unformatted ASCII data file (one 
%                file per particle field); set to 'tecplot' to save a 
%                Tecplot-compatible data file (one combined file).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    args = struct(...
      'datafolder'           , 'C:\Users\erina\California Institute of Technology\104c_erina\swimming_trajectory_002', ...
      'inroot'               , 'time_', ...
      'outroot'              , 'CSC_time_', ...
      'first'                , 1, ...
      'last'                 , 58, ...
      'increment'            , 1, ...
      'numformat'            , '%d', ...
      'fileextension'        , '.dat', ...
      'separator'            , ',', ...
      'numheaderlines'       , 0, ...
      'lengthcalib_axis'     , 1, ...
      'numparticlefields'    , 15, ...
      'export_first'         , 1, ...
      'export_last'          , 58, ...
      'export_increment'     , 1, ...
      'xoutnodes'            , 64, ...
      'youtnodes'            , 64, ...
      'zoutnodes'            , 64, ...
      'plot_delay'           , 1, ...
      'export_data'          , 1, ...
      'export_format'        , 'ascii' ... 
    );