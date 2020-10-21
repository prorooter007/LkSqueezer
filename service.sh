#!/system/bin/sh
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script
# and module is placed.
# This will make sure your module will still work
# if Magisk change its mount point in the future
MODDIR=${0%/*}
# This script will be executed in late_start service mode

# Blackened Mod [SenpaiYank LKSqueezer Adaptation] v1.0 by the
# open source loving BlackenedMod team @ XDA; 
# Various strictly selected, carefully optimized & adjusted      
# tweaks for better day to day performance & battery life,
# specially tuned for the Google Pixel 3 (XL) line-up (Mi A1 in this case)
#

# LKsqueezer is based off this gem ^
# most of the credits go to the its dev team, I've only tuned some parameters and added a couple specific tweaks to it 
# some bits taken from Sohil876's LkSqueezer-Mod, found at https://github.com/Sohil876/LkSqueezer-Mod

# @SenpaiYank

# Halt the execution to make sure the system is properly ready and minimize the chances of something overwriting the changes;
if [[ $MODDIR == "/system/bin" ]]; then
  echo "Dev mode."
else
  echo "Delaying service..."
  sleep 64
  stop perfd
fi

LOG_FILE=/storage/emulated/0/logs/lksqueezer.txt
SCHED_FILE=/storage/emulated/0/logs/.lksfive.ios

# Create the dir for the log file in case it doesn't exist;
if [[ ! -e /storage/emulated/0/logs ]]; then
  mkdir /storage/emulated/0/logs
fi

# Redirect all the output to the log file after clearing it and create a dedicated function for logging;
echo -n "" > $LOG_FILE
#exec &>> $LOG_FILE
LOG () {
   echo "[$(date +"%Y/%m/%d.%T")] lksqueezer: $1" >> $LOG_FILE
}

# Start logging
LOG "starting...!"

# Create the IOsched definition file in case it doesn't exist and default it to cfq;
if [[ ! -e $SCHED_FILE ]]; then
  LOG "first time huh? ;]"
  echo "cfq" > $SCHED_FILE
fi

# Disable fsync for more IO throughput (thus faster initialization once again);
# echo "N" > /sys/module/sync/parameters/fsync_enabled
# reverted for safety reasons and clarified misconception about it

# Tweak the kernel task scheduler for improved overall system performance and user interface responsivness during all kind of possible workload based scenarios;
echo "GENTLE_FAIR_SLEEPERS" > /sys/kernel/debug/sched_features
echo "NO_LB_BIAS" >  /sys/kernel/debug/sched_features
echo "TTWU_QUEUE" > /sys/kernel/debug/sched_features
echo "NO_RT_PUSH_IPI" >  /sys/kernel/debug/sched_features
echo "NO_RT_RUNTIME_SHARE" > /sys/kernel/debug/sched_features
echo "FBT_STRICT_ORDER" > /sys/kernel/debug/sched_features
echo "NO_EAS_USE_NEED_IDLE" > /sys/kernel/debug/sched_features
echo "NO_STUNE_BOOST_BIAS_BIG" > /sys/kernel/debug/sched_features
echo "NEXT_BUDDY" >  /sys/kernel/debug/sched_features

# Disable exception-trace and reduce some overhead that is caused by a certain amount and percent of kernel logging, in case your kernel of choice have it enabled;
echo "0" > /proc/sys/debug/exception-trace

# Disable in-kernel sched statistics for reduced overhead;
echo "0" > /proc/sys/kernel/sched_schedstats

# A couple of minor kernel entropy tweaks & enhancements for a slight UI responsivness boost;
echo "72" > /proc/sys/kernel/random/urandom_min_reseed_secs
echo "128" > /proc/sys/kernel/random/read_wakeup_threshold
echo "384" > /proc/sys/kernel/random/write_wakeup_threshold

# Network tweaks for slightly reduced battery consumption when being "actively" connected to a network connection;
echo "128" > /proc/sys/net/core/netdev_max_backlog
echo "0" > /proc/sys/net/core/netdev_tstamp_prequeue
echo "0" > /proc/sys/net/ipv4/cipso_cache_bucket_size
echo "0" > /proc/sys/net/ipv4/cipso_cache_enable
echo "0" > /proc/sys/net/ipv4/cipso_rbm_strictvalid
echo "0" > /proc/sys/net/ipv4/igmp_link_local_mcast_reports
echo "24" > /proc/sys/net/ipv4/ipfrag_time
echo "westwood" > /proc/sys/net/ipv4/tcp_congestion_control
echo "1" > /proc/sys/net/ipv4/tcp_ecn
echo "0" > /proc/sys/net/ipv4/tcp_fwmark_accept
echo "320" > /proc/sys/net/ipv4/tcp_keepalive_intvl
echo "21600" > /proc/sys/net/ipv4/tcp_keepalive_time
echo "1" > /proc/sys/net/ipv4/tcp_no_metrics_save
echo "1800" > /proc/sys/net/ipv4/tcp_probe_interval
echo "0" > /proc/sys/net/ipv4/tcp_slow_start_after_idle
echo "0" > /proc/sys/net/ipv6/calipso_cache_bucket_size
echo "0" > /proc/sys/net/ipv6/calipso_cache_enable
echo "48" > /proc/sys/net/ipv6/ip6frag_time

# Tweak and decrease tx_queue_len default stock value(s) for less amount of generated bufferbloat and for gaining slightly faster network speed and performance;
for i in $(find /sys/class/net -type l); do
  echo "128" > $i/tx_queue_len
done

# Kernel based tweaks that reduces the total amount of wasted CPU cycles and gives back a huge amount of needed performance as well as battery life savings to both the whole system and the user experience itself;
echo "0" > /proc/sys/kernel/panic
echo "0" > /proc/sys/kernel/panic_on_oops
echo "0" > /proc/sys/kernel/perf_cpu_time_max_percent
echo "20000000" > /proc/sys/kernel/sched_latency_ns
echo "1000000" > /proc/sys/kernel/sched_min_granularity_ns
echo "10000000" > /proc/sys/kernel/sched_wakeup_granularity_ns

# Set the CPU governor to pixel_smurfutil and refine for a wiser frequency selection on MiA1's SoC (S625);
# also, set the max frequency when the screen is off to 1401Mhz;
echo "pixel_smurfutil" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo "5" > /sys/devices/system/cpu/cpufreq/pixel_smurfutil/bit_shift1
echo "5" > /sys/devices/system/cpu/cpufreq/pixel_smurfutil/bit_shift1_2
echo "3" > /sys/devices/system/cpu/cpufreq/pixel_smurfutil/bit_shift2
echo "2000" > /sys/devices/system/cpu/cpufreq/pixel_smurfutil/down_rate_limit_us
echo "1401600" > /sys/devices/system/cpu/cpufreq/pixel_smurfutil/gold_suspend_max_freq
echo "1401600" > /sys/devices/system/cpu/cpufreq/pixel_smurfutil/hispeed_freq
echo "80" > /sys/devices/system/cpu/cpufreq/pixel_smurfutil/hispeed_load
echo "0" > /sys/devices/system/cpu/cpufreq/pixel_smurfutil/iowait_boost_enable
echo "1" > /sys/devices/system/cpu/cpufreq/pixel_smurfutil/pl
echo "1401600" > /sys/devices/system/cpu/cpufreq/pixel_smurfutil/silver_suspend_max_freq
echo "6" > /sys/devices/system/cpu/cpufreq/pixel_smurfutil/suspend_capacity_factor
echo "40" > /sys/devices/system/cpu/cpufreq/pixel_smurfutil/target_load1
echo "88" > /sys/devices/system/cpu/cpufreq/pixel_smurfutil/target_load2
echo "1000" > /sys/devices/system/cpu/cpufreq/pixel_smurfutil/up_rate_limit_us
# ^ Backup

# Set the CPU governor to lightningutil (same as above but with the tunings already applied) 
#echo "lightningutil" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

# Tune lightningutil governor with new values;
#echo "3" > /sys/devices/system/cpu/cpufreq/lightningutil/bit_shift2
#echo "3" > /sys/devices/system/cpu/cpufreq/lightningutil/bit_shift1
#echo "3" > /sys/devices/system/cpu/cpufreq/lightningutil/bit_shift1_2
#echo "94" > /sys/devices/system/cpu/cpufreq/lightningutil/hispeed_load
#echo "2016000" > /sys/devices/system/cpu/cpufreq/lightningutil/hispeed_freq
#echo "34" > /sys/devices/system/cpu/cpufreq/lightningutil/target_load1
#echo "80" > /sys/devices/system/cpu/cpufreq/lightningutil/target_load2
#echo "1000" > /sys/devices/system/cpu/cpufreq/lightningutil/up_rate_limit_us
#echo "3000" > /sys/devices/system/cpu/cpufreq/lightningutil/down_rate_limit_us

# Aggressively tune stune boost values for better battery life;
echo "-64" > /dev/stune/background/schedtune.boost
echo "-32" > /dev/stune/foreground/schedtune.boost
echo "0" > /dev/stune/top-app/schedtune.boost
echo "12" > /sys/module/cpu_boost/parameters/dynamic_stune_boost
echo "192" > /sys/module/cpu_boost/parameters/dynamic_stune_boost_ms

# Set-up the CPUSet groups for performance and efficiency;
echo "2-3" > /dev/cpuset/background/cpus
echo "0-7" > /dev/cpuset/camera-daemon/cpus
echo "4-7" > /dev/cpuset/foreground/cpus
echo "0-1" > /dev/cpuset/restricted/cpus
echo "0-3" > /dev/cpuset/system-background/cpus
echo "2-7" > /dev/cpuset/top-app/cpus

# Virtual Memory tweaks & enhancements for a (massively?) improved balance between performance and battery life;
echo "0" > /proc/sys/vm/compact_unevictable_allowed
echo "0" > /proc/sys/vm/oom_dump_tasks
echo "1200" > /proc/sys/vm/stat_interval
echo "100" > /proc/sys/vm/swappiness
echo "12" > /proc/sys/vm/dirty_ratio
echo "3" > /proc/sys/vm/dirty_background_ratio
echo "3000" > /proc/sys/vm/dirty_writeback_centisecs
echo "500" > /proc/sys/vm/dirty_expire_centisecs
echo "48" > /proc/sys/vm/vfs_cache_pressure

# fstrim the respective partitions for a faster initialization process;
fstrim /cache
fstrim /system
fstrim /data

# Mounting tweak for better overall partition performance;
busybox mount -o remount,nosuid,nodev,noatime,nodiratime,relatime -t auto /
busybox mount -o remount,nosuid,nodev,noatime,nodiratime,relatime -t auto /proc
busybox mount -o remount,nosuid,nodev,noatime,nodiratime,relatime -t auto /sys

# Same for data but disable background gc for f2fs;
if mount | grep -q f2fs; then
  busybox mount -o remount,nosuid,nodev,noatime,nodiratime,relatime,background_gc=off,fsync_mode=nobarrier -t auto /data
  LOG "f2fs FTW!"
else
  busybox mount -o remount,nosuid,nodev,noatime,nodiratime,relatime,barrier=0,noauto_da_alloc,discard -t auto /data
fi

# FileSystem (FS) optimized tweaks & enhancements for a improved userspace experience;
echo "0" > /proc/sys/fs/dir-notify-enable
echo "20" > /proc/sys/fs/lease-break-time

# Wide block based tuning for reduced lag and less possible amount of general IO scheduling based overhead (Thanks to pkgnex @ XDA for the more than pretty much simplified version of this tweak. You really rock, dude!);

i=/sys/block/mmcblk0/queue
echo "0" > $i/add_random
echo "0" > $i/io_poll
echo "1" > $i/iostats
echo "0" > $i/nomerges
#echo "1024" > $i/nr_requests
echo "64" > $i/read_ahead_kb
echo "0" > $i/rotational
echo "1" > $i/rq_affinity
echo "write through" > $i/write_cache

# Set the IO scheduler based on preference (defined in the sched file);
SCHED=$(<$SCHED_FILE)
echo $SCHED > /sys/block/mmcblk0/queue/scheduler

if [[ $SCHED == "cfq" ]]; then
# Tune it for lower latency and fair throughput;
  echo "1" > /sys/block/mmcblk0/queue/iosched/low_latency
  echo "32768" > /sys/block/mmcblk0/queue/iosched/back_seek_max
  echo "1" > /sys/block/mmcblk0/queue/iosched/back_seek_penalty
  echo "1" > /sys/block/mmcblk0/queue/iosched/group_idle
  echo "200" > /sys/block/mmcblk0/queue/iosched/target_latency
  echo "16" > /sys/block/mmcblk0/queue/iosched/quantum
  LOG "CFQ the leader!"
elif [[ $SCHED == "bfq" ]]; then
# Lower timeout_sync for a lower process time budget;
  echo "92" > /sys/block/mmcblk0/queue/iosched/timeout_sync
  LOG "bfq huh?"
elif [[ $SCHED == "deadline" ]]; then
# Tune deadline for even lower latencies and an ENERGETIC behavior (lmao);
  echo "2" > /sys/block/mmcblk0/queue/iosched/fifo_batch
  echo "10" > /sys/block/mmcblk0/queue/iosched/read_expire
  echo "50" > /sys/block/mmcblk0/queue/iosched/write_expire
  echo "3" > /sys/block/mmcblk0/queue/iosched/writes_starved
  LOG "welcome to the deadline gang :D"
fi;

# Set GPU default power level to 6 (133Mhz) for a better batttery life;
echo "6" > /sys/class/kgsl/kgsl-3d0/default_pwrlevel

# Enable and adjust adreno idler for a rather battery aggressive behavior;
echo "Y" > /sys/module/adreno_idler/parameters/adreno_idler_active
echo "20" > /sys/module/adreno_idler/parameters/adreno_idler_downdifferential
echo "24" > /sys/module/adreno_idler/parameters/adreno_idler_idlewait
echo "6144" > /sys/module/adreno_idler/parameters/adreno_idler_idleworkload

# Use RCU_normal instead of RCU_expedited for improved real-time latency, CPU utilization and energy efficiency;
echo "1" > /sys/kernel/rcu_normal

# Enable adreno boost and set it to low for better gpu up ramping // Reverted in favor of the powerHAL backed boosting; 
echo "0" > /sys/class/kgsl/kgsl-3d0/devfreq/adrenoboost

# Set the power suspend mode to 3 (Hybrid, a combination between LCD and Autosleep modes);
echo "3" > /sys/kernel/power_suspend/power_suspend_mode

# Block harmless wakelocks to maximize sleeping time
echo "qcom_rx_wakelock;wlan;wlan_wow_wl;wlan_extscan_wl;netmgr_wl;NETLINK;7000000.ssusb" > /sys/class/misc/boeffla_wakelock_blocker/wakelock_blocker

# Fully disable kernel printk console log spamming directly for less amount of useless wakeups (reduces overhead);
echo "0 0 0 0" > /proc/sys/kernel/printk

# IO flush and drop caches;
sync
echo "3" > /proc/sys/vm/drop_caches

# Voilà - everything done - report it in the log file;
LOG "voilà!"
if [[ $MODDIR != "/system/bin" ]]; then
  LOG "module ran successfully!"
  start perfd
fi
