import sys

ROS_DISTRO = 'rolling'
sys.path.insert(0, f'/opt/ros/{ROS_DISTRO}/lib/python3.121/site-packages')

import numpy as np
import pandas as pd
from matplotlib import pyplot as plt

from tracetools_analysis.loading import load_file
from tracetools_analysis.processor.ros2 import Ros2Handler
from tracetools_analysis.utils.ros2 import Ros2DataModelUtil

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
        dropped, total = [int(x) for x in stats.split("/")]
        dropped_jobs[name.strip()] = float(dropped) / float(total)
    return dropped_jobs

def get_node_name(owner_info):
  node_name = owner_info.split(",")[0].split(":")[1].strip()
  return node_name

events = load_file('~/.ros/tracing/timers-only-events-ro')

# Load trace directory or converted trace file
events_dict = {}
events_dict["rm_ro"] = (load_file('~/.ros/tracing/timers-only-rm-ro'), load_dropped_jobs('timers-only-rm-ro.log'))
# events_dict["rm_re"] = (load_file('~/.ros/tracing/timers-only-rm-re'), load_dropped_jobs('timers-only-rm-re.log'))
# events_dict["edf_ro"] = (load_file('~/.ros/tracing/timers-only-edf-ro'), load_dropped_jobs('timers-only-edf-ro.log'))
# events_dict["edf_re"] = (load_file('~/.ros/tracing/timers-only-edf-re'), load_dropped_jobs('timers-only-edf-re.log'))
events_dict["events_ro"] = (load_file('~/.ros/tracing/timers-only-events-ro'), load_dropped_jobs('timers-only-events-ro.log'))
events_dict["events_re"] = (load_file('~/.ros/tracing/timers-only-events-re'), load_dropped_jobs('timers-only-events-re.log'))
events_dict["default"] = (load_file('~/.ros/tracing/timers-only-default'), load_dropped_jobs('timers-only-default.log'))

dropped_df = pd.DataFrame({"Executor": [], "Node": [], "Drop Rate": []})
wcet_dict = {}

for name, events in events_dict.items():
  dropped_jobs = events[1]
  for node, drop_rate in dropped_jobs.items():
    dropped_df = pd.concat([pd.DataFrame([[name, node, drop_rate]], columns=dropped_df.columns), dropped_df], ignore_index=True)

  # Process
  handler = Ros2Handler.process(events[0])

  # Use data model utils to extract information
  data_util = Ros2DataModelUtil(handler.data)
  callback_symbols = data_util.get_callback_symbols()

  # callback_symbols = ros2_util.get_callback_symbols()
  for callback_object in callback_symbols.keys():
    owner_info = data_util.get_callback_owner_info(callback_object)
    if "parameter_events" in owner_info:
      continue
    owner_name = get_node_name(owner_info)
    # callback_durations = data_util.get_callback_durations(callback_object)
    callback_durations = data_util.get_callback_durations(callback_object)[["duration"]].to_numpy(dtype=np.float64) / 1000000000.0
    if owner_name not in wcet_dict:
      wcet_dict[owner_name] = callback_durations
    else:
      wcet_dict[owner_name] = np.concatenate((wcet_dict[owner_name], callback_durations))

    # print(time_per_thread)
    print(owner_info)
    print(callback_durations)

total_drops_df = dropped_df[dropped_df["Node"] == "Total"]

fig, ax = plt.subplots()
ax.bar(total_drops_df["Executor"], total_drops_df["Drop Rate"])
ax.set_title("Drop Rate by Executor")
plt.show()

fig, ax = plt.subplots()
ax.violinplot(wcet_dict.values(), showmeans=True)
ax.set_title("WCET by Node")
ax.set_xticklabels(wcet_dict.keys())
plt.show()

print(dropped_df)
print(wcet_dict)