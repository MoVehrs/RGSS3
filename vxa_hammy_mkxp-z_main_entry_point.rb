# frozen_string_literal: true
# encoding: utf-8
#==============================================================================
# ▼ Hammy - MKXP-Z Main Entry Point v1.00
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# -- Last Updated: 08.05.2026
# -- Requires: mkxp-z (Ruby 3.1)
# -- Recommended: None
# -- Credits: 姫HimeWorks (Custom Main - Full Error Backtrace),
#             Archeia & Neonblack (RPG Maker VXAce Profiler)
# -- License: MIT License
#==============================================================================

$imported = {} if $imported.nil?
$imported[:hammy_mkxp_z_main_entry_point] = true

#==============================================================================
# ▼ Updates
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 08.05.2026 - Added FORCE_TEST_MODE setting to explicitly set $TEST to true
#              at startup, allowing mkxp-z to replicate Test Play behavior
#              independently of the RPG Maker VX Ace editor launch method.
#              (v1.01)
# 07.05.2026 - Initial release. (v1.00)
# 
#==============================================================================
# ▼ Introduction
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script provides an enhanced main entry point for mkxp-z RPG Maker VX Ace
# games, replacing the default Main script with improved error handling,
# configurable screen resolution, and F12 reset behavior.
# 
# The system supports deferred log file creation with on-demand disk writes,
# timestamped console output, stdout and stderr redirection to dated log files,
# enhanced error backtrace processing with readable script names, configurable
# output buffering, and a built-in TracePoint profiler for performance analysis.
# 
# -----------------------------------------------------------------------------
# ► Core Entry Point Features
# -----------------------------------------------------------------------------
# ★ Deferred log file creation - files only written when output is produced
# ★ Crash log capture independent of session logging setting
# ★ Enhanced error backtrace with readable script names instead of indices
# ★ Timestamped console output via puts override
# 
# -----------------------------------------------------------------------------
# ► Customization System
# -----------------------------------------------------------------------------
# ★ Configurable screen resolution with Yanfly Core Engine compatibility
# ★ Configurable logging enable/disable as standalone setting
# ★ Configurable F12 reset transition effect and duration
# ★ Configurable profiler trigger key, output folder, and noise threshold
# 
# -----------------------------------------------------------------------------
# ► Technical Features
# -----------------------------------------------------------------------------
# ★ Ruby 3.1 syntax with modern module instance variable conventions
# ★ mkxp-z specific RGSSReset handling with optional snapshot transition
# ★ TracePoint-based method call tracking with self and total time calculation
# ★ LogDispatcher class for deferred IO with automatic stderr rebinding
# 
#==============================================================================
# ▼ Base Classes & Method Modifications
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script modifies the following RGSS3 base classes:
# 
# -----------------------------------------------------------------------------
# ► Kernel (Module)
# -----------------------------------------------------------------------------
# ★ Overridden Methods (only when TIMESTAMPS is true):
#   - puts
# 
# -----------------------------------------------------------------------------
# ► Scene_Base (Class)
# -----------------------------------------------------------------------------
# ★ Alias Methods (only when PROFILER_ENABLED is true):
#   - update → main_entry_point_scene_base_update
# 
#==============================================================================
# ▼ General Setup & Usage Guide
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This section explains how to use the built-in profiler and interpret its
# output reports.
# 
# -----------------------------------------------------------------------------
# ► Triggering a Profiler Report
# -----------------------------------------------------------------------------
# Press the configured trigger key (default: F9) during gameplay to write a
# profiler report to the configured output folder. The profiler session resets
# automatically after each report is written.
# 
# ★ Report files are named: profiler_TIMESTAMP_INDEX.log
# 
# -----------------------------------------------------------------------------
# ► Reading the Report Format
# -----------------------------------------------------------------------------
# Each row in the report represents one method tracked during the session.
# Rows are sorted by self time, placing the largest bottlenecks at the top.
# 
# ★ Report column reference:
# 
#      %   cumulative  self             self     total
#    time   seconds   seconds   calls  ms/call  ms/call   name
#   45.23      2.34      2.34     150    15.60    15.60   Game_Character#update
# 
#   - % time:    Percentage of total session time spent in this method
#   - self sec:  Time spent inside this method excluding called methods
#   - total sec: Cumulative time including all methods called from this one
#   - calls:     Number of times this method was invoked
#   - ms/call:   Average milliseconds per invocation
# 
# -----------------------------------------------------------------------------
# ► Profiling Tips
# -----------------------------------------------------------------------------
# ★ Profile for at least 30-60 seconds for statistically meaningful data
# ★ Test specific scenarios separately (menus, battles, map movement)
# ★ High % time indicates an optimization candidate
# ★ High call count with low time indicates normal getters or setters
# 
#==============================================================================
# ▼ Instructions
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# To install this script, open up your script editor and locate ▼ Main. Delete
# or comment out the original Main script contents, then copy/paste this script
# in its place. Remember to save.
# 
# ★ This script REPLACES the default Main script - do not place it in a slot
#   below ▼ Materials/素材. It must be in the ▼ Main section at the bottom.
# 
#==============================================================================
# ▼ Compatibility
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script is made strictly for RPG Maker VX Ace running on mkxp-z.
# It will not run on default RPG Maker VX Ace without mkxp-z.
# 
#==============================================================================

#==============================================================================
# ** Main Entry Point Configuration
#------------------------------------------------------------------------------
#  Configuration settings for the Main Entry Point system.
#==============================================================================

module Hammy
  module MainEntryPoint
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Screen Resolution Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure the game window dimensions in pixels. When Yanfly Ace Core
    # Engine is present, these settings are ignored.
    # 
    # SCREEN_WIDTH: Width of the game window in pixels
    # SCREEN_HEIGHT: Height of the game window in pixels
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    SCREEN_WIDTH = 544
    SCREEN_HEIGHT = 416
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Test Mode Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure forced test mode for use with mkxp-z, where $TEST is not set
    # automatically when launching via the RPG Maker VX Ace Test Play button.
    # 
    # FORCE_TEST_MODE: Force $TEST to true at startup regardless of launch mode
    #   Enable this when running through mkxp-z to replicate Test Play behavior
    #   Disable this before distributing or building a release version
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    FORCE_TEST_MODE = false
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Reset Transition Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure the transition effect applied when F12 reset is triggered.
    # 
    # RESET_USE_SNAPSHOT_TRANSITION: Show transition effect on F12 reset
    #   When false, resets instantly without a transition effect
    # RESET_TRANSITION_DURATION: Duration of the reset transition in frames
    #   Only applies when RESET_USE_SNAPSHOT_TRANSITION is true
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    RESET_USE_SNAPSHOT_TRANSITION = false
    RESET_TRANSITION_DURATION = 10
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Log File Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure log file output including activation, filename format, and
    # output location for all session log files.
    # 
    # LOGGING_ENABLED: Redirect stdout and stderr output to a log file
    #   When true, session output is written to a dated log file on disk
    # LOG_ON_CRASH: Write a crash log when LOGGING_ENABLED is false
    #   When false, no crash log is written and the path msgbox is suppressed
    # LOG_FILENAME_PREFIX: Base filename string prepended before the timestamp
    # LOG_FILENAME_EXTENSION: File extension for log files without the dot
    # LOG_FOLDER: Subfolder path for log files, or nil for the root directory
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    LOGGING_ENABLED = true
    LOG_ON_CRASH = true
    LOG_FILENAME_PREFIX = "mkxp_z_"
    LOG_FILENAME_EXTENSION = "log"
    LOG_FOLDER = "Logs"
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Date Format Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure the timestamp format used in all log and profiler filenames.
    # 
    # DATE_FORMAT: Timestamp format string using Ruby strftime syntax
    #   Shared across session log files and profiler report files
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    DATE_FORMAT = "%d.%m.%Y_%H-%M-%S"
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Output Buffering Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure whether log output is written immediately or held in a buffer.
    # 
    # SYNC_MODE: Flush log output to disk immediately on each write
    #   When false, output is buffered for better write performance
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    SYNC_MODE = false
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Timestamp Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure timestamp prefixes for console output via puts.
    # 
    # TIMESTAMPS: Prepend a timestamp prefix to all puts output
    # TIMESTAMP_FORMAT: Timestamp format string using Ruby strftime syntax
    #   Only applies when TIMESTAMPS is true
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    TIMESTAMPS = true
    TIMESTAMP_FORMAT = "%H:%M:%S"
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Profiler Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # Configure the TracePoint profiler including activation, trigger key,
    # output location, noise filtering, and class exclusions.
    # 
    # PROFILER_ENABLED: Enable the TracePoint performance profiler
    #   When false, the profiler is not initialized with zero runtime overhead
    # PROFILER_TRIGGER_KEY: Input key that triggers profiler report output
    # PROFILER_SHOW_MSGBOX: Show a confirmation msgbox after writing a report
    #   When false, the report is written silently without pausing gameplay
    # PROFILER_MIN_PERCENT: Minimum time percentage for inclusion in report
    #   Methods below this threshold are excluded; set to 0.0 to include all
    # PROFILER_FILENAME_PREFIX: Base filename string prepended before timestamp
    # PROFILER_LOG_EXTENSION: File extension for profiler report files
    # PROFILER_FOLDER: Subfolder path for profiler files, or nil for root
    # PROFILER_EXCLUDED_CLASSES: Array of class name prefixes to exclude
    #   Classes are matched by prefix using start_with? against the class name
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    PROFILER_ENABLED = false
    PROFILER_TRIGGER_KEY = :F9
    PROFILER_SHOW_MSGBOX = true
    PROFILER_MIN_PERCENT = 0.1
    PROFILER_FILENAME_PREFIX = "profiler_"
    PROFILER_LOG_EXTENSION = "log"
    PROFILER_FOLDER = "Logs/Profiler"
    PROFILER_EXCLUDED_CLASSES = [
      #----------------------------------------------------------------------
      # * Ruby core - high call volume, never actionable bottlenecks
      #----------------------------------------------------------------------
      "Kernel",
      "NilClass",
      "TrueClass",
      "FalseClass",
      "Symbol",
      #----------------------------------------------------------------------
      # * Collections - high churn, noisy output
      #----------------------------------------------------------------------
      "String",
      "Array",
      "Hash",
      "Comparable",
      "Enumerable",
      #----------------------------------------------------------------------
      # * Math/numbers - atomic operations
      #----------------------------------------------------------------------
      "Integer",
      "Float",
      "Math",
      #----------------------------------------------------------------------
      # * IO/File - only relevant for load time debugging
      #----------------------------------------------------------------------
      "IO",
      "File",
      "FileTest",
      #----------------------------------------------------------------------
      # * Internals - never useful in game context
      #----------------------------------------------------------------------
      "Class",
      "Module",
      "GC",
      "Marshal",
      "Regexp",
      "MatchData",
    ]
    
    #==========================================================================
    # ▼ End of Documentation
    #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    # This marks the end of the documentation and configuration section.
    # Everything below this point is the actual script implementation code.
    # 
    # WARNING: Modifying the code below requires advanced Ruby and RGSS3
    # knowledge. Improper changes may cause script errors, game crashes, or
    # data corruption. Only edit if you understand the consequences and have
    # backups of your project.
    #==========================================================================
    
    #------------------------------------------------------------------------
    # * Module Extension
    #------------------------------------------------------------------------
    extend self
    
    #------------------------------------------------------------------------
    # * Public Instance Variables
    #------------------------------------------------------------------------
    attr_reader :log_filename
    
    #------------------------------------------------------------------------
    # * Instance Variables
    #------------------------------------------------------------------------
    @log_filename = nil
    @session_timestamp = nil
    
    #------------------------------------------------------------------------
    # * Session Timestamp Accessor
    #------------------------------------------------------------------------
    def session_timestamp
      @session_timestamp ||= Time.now.strftime(DATE_FORMAT)
    end
    
    #------------------------------------------------------------------------
    # * Generate Log Filename
    #------------------------------------------------------------------------
    def generate_log_filename
      return @log_filename if @log_filename
      
      create_folder_recursive(LOG_FOLDER) if LOG_FOLDER
      filename = "#{LOG_FILENAME_PREFIX}#{session_timestamp}" \
                 ".#{LOG_FILENAME_EXTENSION}"
      @log_filename = LOG_FOLDER ? "#{LOG_FOLDER}/#{filename}" : filename
    end
    
    #------------------------------------------------------------------------
    # * Create Folder Structure Recursively
    #------------------------------------------------------------------------
    def create_folder_recursive(path)
      parts = path.split("/")
      parts.each_index do |i|
        segment = parts[0..i].join("/")
        Dir.mkdir(segment) rescue nil
      end
    end
    
    #==========================================================================
    # ** Hammy::MainEntryPoint::LogDispatcher
    #--------------------------------------------------------------------------
    #  This class handles deferred log file creation for stdout redirection.
    # The physical file is only opened on the first write call.
    #==========================================================================
    
    class LogDispatcher
      #----------------------------------------------------------------------
      # * Object Initialization
      #----------------------------------------------------------------------
      def initialize
        @file = nil
      end
      
      #----------------------------------------------------------------------
      # * Write Output
      #----------------------------------------------------------------------
      def write(str)
        open_file_once!
        @file.write(str)
      end
      
      #----------------------------------------------------------------------
      # * Flush Output Buffer
      #----------------------------------------------------------------------
      def flush
        @file&.flush
      end
      
      #----------------------------------------------------------------------
      # * Sync Mode Accessor
      #----------------------------------------------------------------------
      def sync=(value)
        @sync = value
        @file.sync = value if @file
      end
      
      #----------------------------------------------------------------------
      # * Open Log File on First Write
      #----------------------------------------------------------------------
      def open_file_once!
        return if @file
        
        filename = Hammy::MainEntryPoint.generate_log_filename
        @file = File.new(filename, "w")
        @file.sync = @sync || false
        $stderr.reopen(@file)
      end
      
    end # LogDispatcher
  end # MainEntryPoint
end # Hammy

if Hammy::MainEntryPoint::TIMESTAMPS
  #============================================================================
  # ** Kernel
  #----------------------------------------------------------------------------
  #  A module defining the methods that can be referred to by all classes.
  #  Object class methods are defined in this module, ensuring compatibility
  #  with top-level method redefinition.
  #============================================================================
  
  module Kernel
    #------------------------------------------------------------------------
    # * Print with Timestamp                                     [Overridden]
    #------------------------------------------------------------------------
    def puts(*args)
      if args.empty?
        $stdout.write("\n")
        return
      end
      
      timestamp = Time.now.strftime(Hammy::MainEntryPoint::TIMESTAMP_FORMAT)
      args.each do |arg|
        $stdout.write(arg.nil? ? "\n" : "[#{timestamp}]: #{arg}\n")
      end
    end
    
  end # Kernel
end # if Hammy::MainEntryPoint::TIMESTAMPS

if Hammy::MainEntryPoint::PROFILER_ENABLED
  #============================================================================
  # ** Hammy::Profiler
  #----------------------------------------------------------------------------
  #  This module handles TracePoint-based performance profiling. It tracks
  # method call times and outputs reports via a configured trigger key.
  #============================================================================
  
  module Hammy
    module Profiler
      #----------------------------------------------------------------------
      # * Module Extension
      #----------------------------------------------------------------------
      extend self
      
      #----------------------------------------------------------------------
      # * Instance Variables
      #----------------------------------------------------------------------
      @stacks = {}
      @maps = {}
      @start = 0
      @trace = nil
      @file_index = 0
      
      #----------------------------------------------------------------------
      # * Start Profiling
      #----------------------------------------------------------------------
      def start
        @stacks = {}
        @maps = {}
        @start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        @trace&.disable
        
        @trace = TracePoint.new(:call, :return, :c_call, :c_return) do |tp|
          now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
          stack = (@stacks[Thread.current] ||= [])
          
          case tp.event
          when :call, :c_call
            if Hammy::MainEntryPoint::PROFILER_EXCLUDED_CLASSES
                .any? { |ex| tp.defined_class.to_s.start_with?(ex) }
              stack.push nil
            else
              stack.push [now, 0.0]
            end
          when :return, :c_return
            key = "#{tp.defined_class}##{tp.method_id}"
            tick = stack.pop
            next if tick.nil?
            
            threadmap = (@maps[Thread.current] ||= {})
            data = (threadmap[key] ||= [0, 0.0, 0.0, key])
            
            data[0] += 1
            cost = now - tick[0]
            data[1] += cost
            data[2] += cost - tick[1]
            
            stack[-1][1] += cost if stack[-1]
          end
        end
        
        @trace.enable
      end
      
      #----------------------------------------------------------------------
      # * Output Results
      #----------------------------------------------------------------------
      def write_report
        @trace.disable if @trace
        total = Process.clock_gettime(Process::CLOCK_MONOTONIC) - @start
        total = 0.01 if total <= 0
        
        data = aggregate_data
        filename = generate_profiler_filename
        write_report_file(filename, data, total)
        
        if Hammy::MainEntryPoint::PROFILER_SHOW_MSGBOX
          msgbox "Profiling results written to " \
                 "#{filename}" \
                 ".\nSession tracking has been reset."
        else
          puts "Profiling results written to #{filename}."
        end
      end
      
      #----------------------------------------------------------------------
      # * Aggregate Thread Data
      #----------------------------------------------------------------------
      def aggregate_data
        totals = {}
        @maps.values.each do |threadmap|
          threadmap.each do |key, data|
            total_data = (totals[key] ||= [0, 0.0, 0.0, key])
            total_data[0] += data[0]
            total_data[1] += data[1]
            total_data[2] += data[2]
          end
        end
        
        totals.values.sort_by { |x| -x[2] }
      end
      
      #----------------------------------------------------------------------
      # * Generate Profiler Filename
      #----------------------------------------------------------------------
      def generate_profiler_filename
        @file_index += 1
        session_ts = Hammy::MainEntryPoint.session_timestamp
        profiler_name = "#{Hammy::MainEntryPoint::PROFILER_FILENAME_PREFIX}" \
                          "#{session_ts}_#{@file_index.to_s.rjust(3, '0')}" \
                          ".#{Hammy::MainEntryPoint::PROFILER_LOG_EXTENSION}"
        
        folder = Hammy::MainEntryPoint::PROFILER_FOLDER
        filename = folder ? "#{folder}/#{profiler_name}" : profiler_name
        Hammy::MainEntryPoint.create_folder_recursive(folder) if folder
        filename
      end
      
      #----------------------------------------------------------------------
      # * Write Report File
      #----------------------------------------------------------------------
      def write_report_file(filename, data, total)
        sum = 0
        File.open(filename, "w") do |file|
          file.puts "     %   cumulative   self              self     total"
          file.puts "    time   seconds   seconds    calls  ms/call  ms/call  name"
          
          data.each do |d|
            break if d[2] <= 0.0
            pct = d[2] / total * 100
            next if pct < Hammy::MainEntryPoint::PROFILER_MIN_PERCENT
            sum += d[2]
            
            file.puts sprintf("%8.2f %8.2f  %8.2f %8d %8.2f %8.2f  %s",
              pct,
              sum,
              d[2],
              d[0],
              d[2] * 1000 / d[0],
              d[1] * 1000 / d[0],
              d[3]
            )
          end
        end
      end
      
    end # Profiler
  end # Hammy
  
  #============================================================================
  # ** Scene_Base
  #----------------------------------------------------------------------------
  #  This is a super class of all scenes within the game.
  #============================================================================
  
  class Scene_Base
    #------------------------------------------------------------------------
    # * Alias Method Definitions                                     [Custom]
    #------------------------------------------------------------------------
    alias_method :main_entry_point_scene_base_update, :update unless $@
    
    #------------------------------------------------------------------------
    # * Frame Update                                                  [Alias]
    #------------------------------------------------------------------------
    def update
      main_entry_point_scene_base_update
      
      if Input.trigger?(Hammy::MainEntryPoint::PROFILER_TRIGGER_KEY)
        Hammy::Profiler.write_report
        Hammy::Profiler.start
      end
    end
    
  end # Scene_Base
end # if Hammy::MainEntryPoint::PROFILER_ENABLED

#==============================================================================
# ** Main
#------------------------------------------------------------------------------
#  This processing is executed after module and class definition is finished.
#==============================================================================

#----------------------------------------------------------------------------
# * Apply Forced Test Mode
#----------------------------------------------------------------------------
$TEST = true if Hammy::MainEntryPoint::FORCE_TEST_MODE

#----------------------------------------------------------------------------
# * Resize Screen
#----------------------------------------------------------------------------
unless $imported["YEA-CoreEngine"]
  Graphics.resize_screen(
    Hammy::MainEntryPoint::SCREEN_WIDTH,
    Hammy::MainEntryPoint::SCREEN_HEIGHT
  )
end

#----------------------------------------------------------------------------
# * Initialize Log Redirection
#----------------------------------------------------------------------------
if Hammy::MainEntryPoint::LOGGING_ENABLED
  $stdout = Hammy::MainEntryPoint::LogDispatcher.new
  $stdout.sync = Hammy::MainEntryPoint::SYNC_MODE
end

#----------------------------------------------------------------------------
# * Initialize Profiler
#----------------------------------------------------------------------------
Hammy::Profiler.start if Hammy::MainEntryPoint::PROFILER_ENABLED

#----------------------------------------------------------------------------
# * Main Game Loop
#----------------------------------------------------------------------------
begin
  rgss_main do
    begin
      SceneManager.run
    rescue RGSSReset
      unless Hammy::MainEntryPoint::RESET_USE_SNAPSHOT_TRANSITION
        Graphics.__reset__
        Graphics.transition(0)
      else
        Graphics.transition(Hammy::MainEntryPoint::RESET_TRANSITION_DURATION)
      end
      
      retry
    end
  end
rescue SystemExit
  exit
rescue Exception => error
  scripts_name = load_data('Data/Scripts.rvdata2')
  scripts_name.map! { _1[1] }
  
  backtrace = []
  error.backtrace.each do |line|
    match = line.match(/\{(.*)\}(.*)/)
    if match
      script_index = match[1].to_i
      backtrace << "#{scripts_name[script_index]}#{match[2]}"
    elsif line.start_with?(':1:')
      break
    else
      backtrace << line
    end
  end
  
  error_line = backtrace.first.to_s
  error_msg = "#{error_line}: #{error.message} (#{error.class})"
  backtrace[0] = ''
  
  if !Hammy::MainEntryPoint::LOGGING_ENABLED &&
      Hammy::MainEntryPoint::LOG_ON_CRASH
    $stdout = Hammy::MainEntryPoint::LogDispatcher.new
    $stdout.sync = true
  end
  
  puts "#{error_msg}#{backtrace.join("\n\tfrom ")}"
  
  show_msgbox = Hammy::MainEntryPoint::LOGGING_ENABLED ||
                Hammy::MainEntryPoint::LOG_ON_CRASH
  
  raise error.class,
        show_msgbox ?
          "Error occurred, check the debug console or " \
          "#{Hammy::MainEntryPoint.log_filename}" \
          " for more information." :
          "Error occurred, check the debug console for more information.",
        [error.backtrace.first]
end

#==============================================================================
# 
# ▼ End of File
# 
#==============================================================================
