# %%
import sys
from collections import defaultdict
import re
import os

ROS_DISTRO = 'rolling'
sys.path.insert(0, f'/opt/ros/{ROS_DISTRO}/lib/python3.121/site-packages')

if not os.path.exists("figures"):
  os.makedirs("figures")

import numpy as np
import pandas as pd
from matplotlib import pyplot as plt
import seaborn as sns
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker

from tracetools_analysis.loading import load_file
from tracetools_analysis.processor import Processor
from tracetools_analysis.processor.cpu_time import CpuTimeHandler
from tracetools_analysis.processor.ros2 import Ros2Handler
from tracetools_analysis.utils.cpu_time import CpuTimeDataModelUtil
from tracetools_analysis.utils.ros2 import Ros2DataModelUtil

from multiprocessing import Pool

def load_dropped_jobs(filename):
  with open(filename, 'r') as f:
    dropped_jobs = {}
    process_line = False
    for line in f:
      if line.startswith("Dropped jobs:"):
        process_line = True
        continue
      if process_line:
        name, stats = line.strip().split(":")
        dropped, overrun, total = [int(x) for x in stats.split("/")]
        dropped_jobs[name.strip()] = float(dropped) / float(total) if total > 0 else 0
    return dropped_jobs
def load_inputs(string):
  return (load_file(directory_prefix + string), load_dropped_jobs(directory_prefix + string + '.log'))

def get_node_name(owner_info):
  node_name = owner_info.split(",")[0].split(":")[1].strip()
  return node_name

# %%

# Load trace directory or converted trace file
directory_prefix = "data/"
events_dict = {}

def load_inputs(string):
  return (load_file(directory_prefix + string), load_dropped_jobs(directory_prefix + string + '.log'))

trace_names = ['trace-timers-only.rm.60', 'trace-timers-only.edf.60',
               'trace-timers-only.events.60', 'trace-timers-only.static.60',
               'trace-timers-only.default.60',
               'trace-timers-only.rm.80', 'trace-timers-only.edf.80',
               'trace-timers-only.events.80', 'trace-timers-only.static.80',
               'trace-timers-only.default.80',
               'trace-timers-only.rm.90', 'trace-timers-only.edf.90',
               'trace-timers-only.events.90', 'trace-timers-only.static.90',
               'trace-timers-only.default.90']
display_names = ['RM,60%', 'EDF,60%', 'Events,60%', 'Static,60%', 'Default,60%',
                 'RM,80%', 'EDF,80%', 'Events,80%', 'Static,80%', 'Default,80%',
                 'RM,90%', 'EDF,90%', 'Events,90%', 'Static,90%', 'Default,90%']

# trace_names = ['sequences.rm.ro.uu', 'sequences.rm.re.uu',
#                'sequences.events.ro.uu', 'sequences.events.re.uu',
#                'sequences.default.uu',
#                'sequences.rm.ro.hu', 'sequences.rm.re.hu',
#                'sequences.events.ro.hu', 'sequences.events.re.hu',
#                'sequences.default.hu']
# display_names = ['RM (RO),60%', 'RM (RE),60%', 'Events (RO),60%', 'Events (RE),60%', 'Default,60%',
#                  'RM (RO),100%', 'RM (RE),100%', 'Events (RO),100%', 'Events (RE),100%', 'Default,100%']
# events_dict = {}
# for trace, display in zip(trace_names, display_names):
#   events_dict[display] = load_inputs(trace)

# events_dict["RM, (RO)"] =     (load_file(directory_prefix + 'timers-only-rm-ro'),     load_dropped_jobs(directory_prefix + 'timers-only-rm-ro.log'))
# events_dict["RM, (RE)"] =     (load_file(directory_prefix + 'timers-only-rm-re'),     load_dropped_jobs(directory_prefix + 'timers-only-rm-re.log'))
# events_dict["EDF, (RO)"] =    (load_file(directory_prefix + 'timers-only-edf-ro'),    load_dropped_jobs(directory_prefix + 'timers-only-edf-ro.log'))
# events_dict["EDF, (RE)"] =    (load_file(directory_prefix + 'timers-only-edf-re'),    load_dropped_jobs(directory_prefix + 'timers-only-edf-re.log'))
# events_dict["Events, (RO)"] = (load_file(directory_prefix + 'timers-only-events-ro'), load_dropped_jobs(directory_prefix + 'timers-only-events-ro.log'))
# events_dict["Events, (RE)"] = (load_file(directory_prefix + 'timers-only-events-re'), load_dropped_jobs(directory_prefix + 'timers-only-events-re.log'))
# events_dict["Default"] =      (load_file(directory_prefix + 'timers-only-default'),   load_dropped_jobs(directory_prefix + 'timers-only-default.log'))

dropped_df = pd.DataFrame({"Executor": [], "Utilization": [], "Node": [], "Drop Rate": []})

# %%
callback_df = None
input_data = None
wcet_dict = {}

for trace, display in zip(trace_names, display_names):
  events = load_inputs(trace)
  utilization = display.split(",")[1]
  name = display.split(",")[0]
  dropped_jobs = events[1]
  for node, drop_rate in dropped_jobs.items():
    # temp_df = pd.DataFrame([[name, utilization, node, drop_rate]])
    dropped_df = pd.concat([pd.DataFrame([[name, utilization, node, drop_rate]], columns=dropped_df.columns), dropped_df], ignore_index=True)

  # # Timer manager processing
  # tid = 2750
  # trace_events = pd.DataFrame.from_dict(events[0])[['_name', 'timestamp', 'next_tid', 'prev_tid']]
  # sched_events = trace_events[(trace_events['next_tid']==tid) | (trace_events['prev_tid']==tid)]

  # Process
  if len(events[0]) == 0:
    print("No events found for " + name)
    continue
  handler = Ros2Handler.process(events[0])

  # Use data model utils to extract information
  data_util = Ros2DataModelUtil(handler.data)
  callback_symbols = data_util.get_callback_symbols()

  if utilization != "90%":
    continue
  
  # callback_symbols = ros2_util.get_callback_symbols()
  for callback_object in callback_symbols.keys():
    owner_info = data_util.get_callback_owner_info(callback_object)
    if "parameter_events" in owner_info:
      continue
    owner_name = get_node_name(owner_info)
    temp_df = data_util.get_callback_durations(callback_object)
    temp_df["Executor"] = name
    temp_df["Node"] = owner_name
    if callback_df is None:
      callback_df = temp_df
    else:
      callback_df = pd.concat([callback_df, temp_df], ignore_index=True)

    callback_durations = data_util.get_callback_durations(callback_object)[["duration"]].to_numpy(dtype=np.float64)[:-1] / 1000000.0
    
    if (owner_name + name) not in wcet_dict:
      wcet_dict[owner_name + name] = callback_durations.flatten()
    else:
      wcet_dict[owner_name + name] = np.concatenate((wcet_dict[owner_name + name], callback_durations.flatten())).flatten()

    # print(time_per_thread)
    # print(owner_info)
    # print(callback_durations)

total_drops_df = dropped_df[dropped_df["Node"] == "Total"]

# %%
plt.figure(figsize=(7,4))
ax = sns.barplot(total_drops_df, y="Drop Rate", x="Executor", hue="Utilization", palette=["#003f5c", "#7393B3", "#7a7a7a"])
ax.set_title("Timers Only, Uniprocessor")
ax.set_ylabel("Drop Rate")
ax.set_yscale('log')
ax.set_xticklabels(ax.get_xticklabels(), rotation=30)

# ax.set_ylim([0, 1])
plt.savefig("figures/dropped_jobs_timers_only.png", bbox_inches='tight')
# # plt.show()

plt.figure()
wcet_grouped_dict = {"Camera": np.array([]), "Lidar": np.array([]), "IMU": np.array([])}
for k in wcet_dict.keys():
  # wcet_dict[k] = wcet_dict[k][wcet_dict[k] < 0.1]
  if "camera" in k.lower():
    wcet_grouped_dict["Camera"] = np.concatenate((wcet_grouped_dict["Camera"], wcet_dict[k]))
  elif "lidar" in k.lower():
    wcet_grouped_dict["Lidar"] = np.concatenate((wcet_grouped_dict["Lidar"], wcet_dict[k]))
  elif "imu" in k.lower():
    wcet_grouped_dict["IMU"] = np.concatenate((wcet_grouped_dict["IMU"], wcet_dict[k]))
sns.violinplot(wcet_grouped_dict)
plt.title("Timers Only, Uniprocessor")
plt.ylabel("WCET (ms)")
plt.savefig("figures/wcet_timers_only_grouped.png", bbox_inches='tight')
# plt.show()
wcet_grouped_dict["IMU"].sort()
print(wcet_grouped_dict["IMU"][-10:])

plt.figure(figsize=(30,4))
ax = sns.violinplot(wcet_dict)
ax.set_xticklabels(ax.get_xticklabels(), rotation=30)
plt.title("Timers Only, Uniprocessor")
plt.ylabel("WCET (ms)")
plt.savefig("figures/wcet_timers_only.png", bbox_inches='tight')
# plt.show()


# TODO: Pie chart of which types of jobs are dropped

# %%
import os

# Define the regex pattern to match directories with the format ##s
time_pattern = re.compile(r'^\d+s$')

# List all directories in the autoware_benchmark folder
benchmark_dirs = os.listdir("./data/autoware_benchmark/")

# Filter directories that match the time pattern
time_dirs = [d for d in benchmark_dirs if time_pattern.match(d)]

# Check the number of matching directories
if len(time_dirs) == 1:
    duration = int(time_dirs[0][:-1])
    print(f"Using duration: {duration}s")
elif len(time_dirs) > 1:
    prompt_str = "Multiple durations found. Enter the number of your choice ("
    for i, d in enumerate(time_dirs):
        prompt_str += f"{i + 1}: {d}, "
    prompt_str = prompt_str[:-2] + "): "
    choice = int(input(prompt_str)) - 1
    duration = int(time_dirs[choice][:-1])
    print(f"Using duration: {duration}s")
else:
    raise RuntimeError("No valid duration directories found in autoware_benchmark.")

directory = f"./data/autoware_benchmark/{duration}s/rmw_cyclonedds_cpp/"

# %%
executors = ["autoware_default_events", "autoware_default_rm", "autoware_default_singlethreaded", "autoware_default_staticsinglethreaded"]
dirs = [directory + e for e in executors]

files = [directory+'/std_output.log' for directory in dirs]

hot_path_name = None

# result maps each pair (exe, rmw) to lists of results corresponding to the runs
results = defaultdict(lambda: [])

hot_path_name_regex = re.compile(r'^ *hot path: *(.*)$')
hot_path_latency_regex = re.compile(r'^ *hot path latency: *(.+)ms \[min=(.+)ms, ' +
                                    r'max=(.+)ms, average=(.+)ms, deviation=(.+)ms\]$')
hot_path_drops_regex = re.compile(r'^ *hot path drops: *(.+) \[min=(.+), max=(.+), ' +
                                  r'average=(.+), deviation=(.+)\]$')
behavior_planner_period_regex = re.compile(r'^ *behavior planner period: *(.+)ms \[' +
                                            r'min=(.+)ms, max=(.+)ms, average=(.+)ms, ' +
                                            r'deviation=(.+)ms\]$')

rmw_regex = re.compile(r'^RMW Implementation: (rmw_.*)')
filename_regex = re.compile(r'.*/([0-9]+)s/(rmw_.*)/(.*)/std_output.log')
for count, file in enumerate(files):
    match = filename_regex.match(file)
    if not match:
        raise ValueError(f'File {file} does not conform to the naming scheme')

    extracted_duration, rmw, exe = match.groups()
    if int(extracted_duration) != duration:
        raise ValueError(f'File {file} does not match expected duration {duration}')
    with open(file) as fp:
        rmw_line, *data = fp.read().splitlines()

    match = rmw_regex.match(rmw_line)
    if match and rmw != match.groups()[0]:
        raise ValueError((f'{file}: mismatch between filename-rmw ("{rmw}")' +
                          f'and content-rmw("{match.groups()[0]}")'))

    if rmw not in file:
        raise ValueError(f'File {file} contains data from RMW {rmw}, contradicting its name')

    for line in data:
        match = hot_path_name_regex.match(line)
        if match:
            name, = match.groups()
            if hot_path_name is not None and hot_path_name != name:
                raise ValueError('Two different hotpaths in a single summary: ' +
                                  f'{name} {hot_path_name}')
            hot_path_name = name
            continue
        match = hot_path_latency_regex.match(line)
        if match:
            results[exe].append(float(match.groups()[0]))
            continue

if hot_path_name is None:
    raise RuntimeError('No hot_path defined in experiment.')

# %%

# Set the style of the plot
# sns.set_style({'axes.facecolor':'white', 'grid.color': '.8'})
# sns.set_context("talk")  # Adjust this for larger or smaller text
# results["autoware_default_events"].sort()
# # results["autoware_default_fifo"].sort()
# results["autoware_default_rm"].sort()
# results["autoware_default_singlethreaded"].sort()
# results["autoware_default_staticsinglethreaded"].sort()
# print(results["autoware_default_events"][-5:])
# # print(results["autoware_default_fifo"][-5:])
# print(results["autoware_default_rm"][-5:])
# print(results["autoware_default_singlethreaded"][-5:])
# print(results["autoware_default_staticsinglethreaded"][-5:])

# Creating the violin plot with specific color scheme and settings
plt.figure(figsize=(10, 6))  # Adjust the figure size as needed
# ax = sns.boxplot(data=results, color="#2171b5", whis=100, linewidth=1.5, linecolor="#10385a",
#     fliersize=5, showfliers=False)
parts = plt.violinplot([results["autoware_default_singlethreaded"],
                     results["autoware_default_staticsinglethreaded"],
                     results["autoware_default_events"],
                     results["autoware_default_rm"]],
                     positions=[0,1,2,3], showextrema=True)
# for pc in parts['bodies']:
#     pc.set_edgecolor('#ff0000')
ax = sns.violinplot(data=results, palette=["#2171b5", "#2171b5", "#2171b5", "#2171b5"],
                    linewidth=0, inner_kws={"box_width": 0, "whis_width": 0}, cut=0,
                    order=["autoware_default_singlethreaded", "autoware_default_staticsinglethreaded", "autoware_default_events", "autoware_default_rm"])
# sns.boxplot(results, width=1, whis=100)

# Customizing the look and feel of the plot to match the bar graph
ax.set_ylabel("Latency (ms)", fontsize=16, labelpad=10)  # Y-axis Label
ax.set_title("Latency Summary 600s [FrontLidarDriver/RearLidarDriver -> ObjectCollision]", fontsize=16, pad=20)  # Title

# Setting y-axis limits and labels similar to the bar chart
ax.set_ybound(0, 100)  # Y-axis Bounds
ax.yaxis.set_major_locator(ticker.MultipleLocator(10))  # Major ticks every 10 units
ax.yaxis.set_minor_locator(ticker.MultipleLocator(2))   # Minor ticks every 2 units

# Enable grid only for major ticks on the y-axis
ax.grid(True, which='major', linestyle='-', linewidth=0.5)
ax.grid(True, which='minor', linestyle='', linewidth=0)

# Set axis labels
ax.set_yticklabels([int(x) for x in ax.get_yticks()], size=12)  # Y-axis Ticks
ax.set_xticklabels(["Default", "Static", "Events", "RM"], ha="center", fontsize=16)

# Remove top and right borders for a cleaner look
sns.despine(fig=None, ax=None, top=True, right=True, left=False, bottom=False, offset=None, trim=False)

# Show the plot
plt.savefig("figures/latency_violin.png")
# plt.show()

# %%
import os
import pandas as pd

root_dir = "data/"

samples = {}
lidar_array = []
imu_array = []
camera_array = []
temp_array = []
df = pd.DataFrame(columns=["Executor", "Utilization", "Node", "Response Time"])
for directory in os.listdir(root_dir):
  if "response_time" in directory:
    utilization = directory.split(".")[-1]
    executor = directory.replace("response_time.", "").replace('.' + utilization, "")
    for file in os.listdir(root_dir + directory):
      temp_array = []
      with open(root_dir + directory + "/" + file, 'r') as fin:
        for line in fin:
          temp_array.append(float(line.split(':')[1].strip())/1000000.0)
      cutoff = np.percentile(temp_array, 99.85)
      temp_array = [x for x in temp_array if x < cutoff]
      if "Lidar" in file:
        df_to_add = pd.DataFrame({"Executor": [executor]*len(temp_array),
                              "Utilization": [utilization]*len(temp_array),
                              "Node": ["Lidar"]*len(temp_array),
                              "Response Time": temp_array})
        df = pd.concat([df, df_to_add])
      elif "IMU" in file:
        df_to_add = pd.DataFrame({"Executor": [executor]*len(temp_array),
                              "Utilization": [utilization]*len(temp_array),
                              "Node": ["IMU"]*len(temp_array),
                              "Response Time": temp_array})
        df = pd.concat([df, df_to_add])
      elif "Camera" in file:
        df_to_add = pd.DataFrame({"Executor": [executor]*len(temp_array),
                              "Utilization": [utilization]*len(temp_array),
                              "Node": ["Camera"]*len(temp_array),
                              "Response Time": temp_array})
        df = pd.concat([df, df_to_add])
    


# %%

plt.figure(figsize=(8,4))
ax = sns.violinplot(data=df[df["Node"] == "Camera"], x="Executor", y="Response Time", hue="Utilization",
    palette=["#004d4c", "#008080", "#5ca3a3"], linewidth=0.5, cut=0, hue_order=["60", "80", "90"],
    order=["default", "static", "events", "edf", "rm"],
    inner_kws={"box_width": 1, "whis_width": 0})
ax.set_title("Response Time, Cameras")
ax.set_ylabel("Response Time (ms)")
# ax.set_ylim([0, 85])
ax.set_xticklabels(["Default", "Static", "Events", "EDF", "RM"], ha="center", rotation=30)

plt.savefig("figures/response_times_cameras.png", bbox_inches='tight')
# plt.show()

print(max(df[(df['Node'] == 'Camera') & (df['Executor'] == 'default') & (df['Utilization'] == '60')]['Response Time']))
print(max(df[(df['Node'] == 'Camera') & (df['Executor'] == 'default') & (df['Utilization'] == '80')]['Response Time']))
print(max(df[(df['Node'] == 'Camera') & (df['Executor'] == 'default') & (df['Utilization'] == '90')]['Response Time']))
print(max(df[(df['Node'] == 'Camera') & (df['Executor'] == 'static') & (df['Utilization'] == '60')]['Response Time']))
print(max(df[(df['Node'] == 'Camera') & (df['Executor'] == 'static') & (df['Utilization'] == '80')]['Response Time']))
print(max(df[(df['Node'] == 'Camera') & (df['Executor'] == 'static') & (df['Utilization'] == '90')]['Response Time']))
print(max(df[(df['Node'] == 'Camera') & (df['Executor'] == 'events') & (df['Utilization'] == '60')]['Response Time']))
print(max(df[(df['Node'] == 'Camera') & (df['Executor'] == 'events') & (df['Utilization'] == '80')]['Response Time']))
print(max(df[(df['Node'] == 'Camera') & (df['Executor'] == 'events') & (df['Utilization'] == '90')]['Response Time']))
print(max(df[(df['Node'] == 'Camera') & (df['Executor'] == 'edf') & (df['Utilization'] == '60')]['Response Time']))
print(max(df[(df['Node'] == 'Camera') & (df['Executor'] == 'edf') & (df['Utilization'] == '80')]['Response Time']))
print(max(df[(df['Node'] == 'Camera') & (df['Executor'] == 'edf') & (df['Utilization'] == '90')]['Response Time']))
print(max(df[(df['Node'] == 'Camera') & (df['Executor'] == 'rm') & (df['Utilization'] == '60')]['Response Time']))
print(max(df[(df['Node'] == 'Camera') & (df['Executor'] == 'rm') & (df['Utilization'] == '80')]['Response Time']))
print(max(df[(df['Node'] == 'Camera') & (df['Executor'] == 'rm') & (df['Utilization'] == '90')]['Response Time']))



plt.figure(figsize=(8,4))
ax = sns.violinplot(data=df[df["Node"] == "Lidar"], x="Executor", y="Response Time", hue="Utilization",
    palette=["#004d4c", "#008080", "#5ca3a3"], linewidth=0.5, cut=0, hue_order=["60", "80", "90"],
    order=["default", "static", "events", "edf", "rm"],
    inner_kws={"box_width": 1, "whis_width": 0})
ax.set_title("Response Time, LiDAR")
ax.set_ylabel("Response Time (ms)")
# ax.set_ylim([0, 200])
ax.set_xticklabels(["Default", "Static", "Events", "EDF", "RM"], ha="center", rotation=30)

plt.savefig("figures/response_times_lidar.png", bbox_inches='tight')
# plt.show()

print(max(df[(df['Node'] == 'Lidar') & (df['Executor'] == 'default') & (df['Utilization'] == '60')]['Response Time']))
print(max(df[(df['Node'] == 'Lidar') & (df['Executor'] == 'default') & (df['Utilization'] == '80')]['Response Time']))
print(max(df[(df['Node'] == 'Lidar') & (df['Executor'] == 'default') & (df['Utilization'] == '90')]['Response Time']))
print(max(df[(df['Node'] == 'Lidar') & (df['Executor'] == 'static') & (df['Utilization'] == '60')]['Response Time']))
print(max(df[(df['Node'] == 'Lidar') & (df['Executor'] == 'static') & (df['Utilization'] == '80')]['Response Time']))
print(max(df[(df['Node'] == 'Lidar') & (df['Executor'] == 'static') & (df['Utilization'] == '90')]['Response Time']))
print(max(df[(df['Node'] == 'Lidar') & (df['Executor'] == 'events') & (df['Utilization'] == '60')]['Response Time']))
print(max(df[(df['Node'] == 'Lidar') & (df['Executor'] == 'events') & (df['Utilization'] == '80')]['Response Time']))
print(max(df[(df['Node'] == 'Lidar') & (df['Executor'] == 'events') & (df['Utilization'] == '90')]['Response Time']))
print(max(df[(df['Node'] == 'Lidar') & (df['Executor'] == 'edf') & (df['Utilization'] == '60')]['Response Time']))
print(max(df[(df['Node'] == 'Lidar') & (df['Executor'] == 'edf') & (df['Utilization'] == '80')]['Response Time']))
print(max(df[(df['Node'] == 'Lidar') & (df['Executor'] == 'edf') & (df['Utilization'] == '90')]['Response Time']))
print(max(df[(df['Node'] == 'Lidar') & (df['Executor'] == 'rm') & (df['Utilization'] == '60')]['Response Time']))
print(max(df[(df['Node'] == 'Lidar') & (df['Executor'] == 'rm') & (df['Utilization'] == '80')]['Response Time']))
print(max(df[(df['Node'] == 'Lidar') & (df['Executor'] == 'rm') & (df['Utilization'] == '90')]['Response Time']))

plt.figure(figsize=(8,4))
ax = sns.violinplot(data=df[df["Node"] == "IMU"], x="Executor", y="Response Time", hue="Utilization",
    palette=["#004d4c", "#008080", "#5ca3a3"], linewidth=0.5, cut=0, hue_order=["60", "80", "90"],
    order=["default", "static", "events", "edf", "rm"],
    inner_kws={"box_width": 1, "whis_width": 0})
ax.set_title("Response Time, IMU")
ax.set_ylabel("Response Time (ms)")
# ax.set_ylim([0, 40])
ax.set_xticklabels(["Default", "Static", "Events", "EDF", "RM"], ha="center", rotation=30)
ax.axhline(y=30, linewidth=1, color='r', linestyle='--')

plt.savefig("figures/response_times_imu.png", bbox_inches='tight')
# plt.show()

print(max(df[(df['Node'] == 'IMU') & (df['Executor'] == 'default') & (df['Utilization'] == '60')]['Response Time']))
print(max(df[(df['Node'] == 'IMU') & (df['Executor'] == 'default') & (df['Utilization'] == '80')]['Response Time']))
print(max(df[(df['Node'] == 'IMU') & (df['Executor'] == 'default') & (df['Utilization'] == '90')]['Response Time']))
print(max(df[(df['Node'] == 'IMU') & (df['Executor'] == 'static') & (df['Utilization'] == '60')]['Response Time']))
print(max(df[(df['Node'] == 'IMU') & (df['Executor'] == 'static') & (df['Utilization'] == '80')]['Response Time']))
print(max(df[(df['Node'] == 'IMU') & (df['Executor'] == 'static') & (df['Utilization'] == '90')]['Response Time']))
print(max(df[(df['Node'] == 'IMU') & (df['Executor'] == 'events') & (df['Utilization'] == '60')]['Response Time']))
print(max(df[(df['Node'] == 'IMU') & (df['Executor'] == 'events') & (df['Utilization'] == '80')]['Response Time']))
print(max(df[(df['Node'] == 'IMU') & (df['Executor'] == 'events') & (df['Utilization'] == '90')]['Response Time']))
print(max(df[(df['Node'] == 'IMU') & (df['Executor'] == 'edf') & (df['Utilization'] == '60')]['Response Time']))
print(max(df[(df['Node'] == 'IMU') & (df['Executor'] == 'edf') & (df['Utilization'] == '80')]['Response Time']))
print(max(df[(df['Node'] == 'IMU') & (df['Executor'] == 'edf') & (df['Utilization'] == '90')]['Response Time']))
print(max(df[(df['Node'] == 'IMU') & (df['Executor'] == 'rm') & (df['Utilization'] == '60')]['Response Time']))
print(max(df[(df['Node'] == 'IMU') & (df['Executor'] == 'rm') & (df['Utilization'] == '80')]['Response Time']))
print(max(df[(df['Node'] == 'IMU') & (df['Executor'] == 'rm') & (df['Utilization'] == '90')]['Response Time']))


