#!/bin/bash
#
# Input parser for i3 bar
# 14 ago 2015 - Electro7

# config
. $(dirname $0)/i3_lemonbar_config

# min init
irc_n_high=0
title="%{F${color_head} B${color_sec_b2}}${sep_right}%{F${color_head} B${color_sec_b2}%{T2} ${icon_prog} %{F${color_sec_b2} B-}${sep_right}%{F- B- T1}"

# parser
while read -r line ; do
  case $line in
    SYS*)
      # conky=, 0 = wday, 1 = mday, 2 = month, 3 = time, 4 = cpu, 5 = mem, 6 = disk /, 7 = disk /home, 8-9 = up/down wlan, 10-11 = up/down eth, 12-13=speed
      sys_arr=(${line#???})
      # date
      if [ ${res_w} -gt 1024 ]; then
        date="${sys_arr[0]} ${sys_arr[1]} ${sys_arr[2]}"
      else
        date="${sys_arr[1]} ${sys_arr[2]}"
      fi
      date="%{F${color_sec_b2}}${sep_left}%{F${color_icon} B${color_sec_b2}} %{T2}${icon_clock}%{F- T1} ${date,,}"
      # time
      time="%{F${color_head}}${sep_left}%{F${color_back} B${color_head}} ${sys_arr[3]} %{F- B-}"
      # cpu
      #if [ ${sys_arr[4]} -gt ${cpu_alert} ]; then
      #  cpu_cback=${color_cpu}; cpu_cicon=${color_back}; cpu_cfore=${color_back};
      #else
        cpu_cback=${color_sec_b2}; cpu_cicon=${color_icon}; cpu_cfore=${color_fore};
      #fi
      cpu="%{F${cpu_cback}}${sep_left}%{F${cpu_cicon} B${cpu_cback}} %{T2}${icon_cpu}%{F${cpu_cfore} T1} ${sys_arr[4]}%"
      # mem
      mem="%{F${cpu_cicon}}${sep_l_left} %{T2}${icon_mem}%{F${cpu_cfore} T1} ${sys_arr[5]}"
      # bat

      if [ ${sys_arr[10]} == "charging" ] || [ ${sys_arr[10]} == "charged" ]; then
        bat_cback=${color_sec_b1}; bat_cicon=${color_icon}; bat_cfore=${color_fore}; icon_bat=${icon_bat_chr};
      elif [ ${sys_arr[11]::-1} -le ${bat_low} ]; then
        bat_cback=${color_chat}; bat_cicon=${color_back}; bat_cfore=${color_back}; icon_bat=${icon_bat_low};
      elif [ ${sys_arr[11]::-1} -le ${bat_med} ]; then
        bat_cback=${color_sec_b1}; bat_cicon=${color_icon}; bat_cfore=${color_fore}; icon_bat=${icon_bat_med};
      else
        bat_cback=${color_sec_b1}; bat_cicon=${color_icon}; bat_cfore=${color_fore}; icon_bat=${icon_bat_high};
      fi

      bat="%{F${bat_cback}}${sep_left}%{F${bat_cicon} B${bat_cback}} %{T2}${icon_bat}%{F${bat_cfore} T1} ${sys_arr[11]}"
      # wlan
      if [ "${sys_arr[8]}" == "down" ]; then
        wland_v="×"; wlanu_v="×";
        wlan_cback=${color_sec_b1}; wlan_cicon=${color_disable}; wlan_cfore=${color_disable};
      else
        wland_v=${sys_arr[8]}K; wlanu_v=${sys_arr[9]}K;
        #if [ ${wland_v:0:-3} -gt ${net_alert} ] || [ ${wlanu_v:0:-3} -gt ${net_alert} ]; then
        #  wlan_cback=${color_net}; wlan_cicon=${color_back}; wlan_cfore=${color_back};
        #else
          wlan_cback=${color_sec_b1}; wlan_cicon=${color_icon}; wlan_cfore=${color_fore};
        #fi
      fi
      wland="%{F${wlan_cback}}${sep_left}%{F${wlan_cicon} B${wlan_cback}} %{T2}${icon_dl}%{F${wlan_cfore} T1} ${wland_v}"
      wlanu="%{F${wlan_cicon}}${sep_l_left} %{T2}${icon_ul}%{F${wlan_cfore} T1} ${wlanu_v}"
      ;;
    VOL*)
      # Volume
      vol="%{F${color_sec_b2}}${sep_left}%{F${color_icon} B${color_sec_b2}} %{T2}${icon_vol}%{F- T1} ${line#???}"
      ;;
    MPD*)
      # Music
      mpd_arr=(${line#???})
      if [ -z "${line#???}" ]; then
        song="none";
      elif [ "${mpd_arr[0]}" == "error:" ]; then
        song="mpd off";
      else
        song="${line#???}";
      fi
      mpd="%{F${color_sec_b2}}${sep_left}%{B${color_sec_b2}}%{F${color_sec_b1}}${sep_left}%{F${color_icon} B${color_sec_b1}} %{T2}${icon_music}%{F${color_fore} T1}  ${song}"
      ;;
    WSP*)
      # I3 Workspaces
      wsp="%{F${color_back} B${color_head}} %{T2}${icon_wsp}%{T1}"
      set -- ${line#???}
      while [ $# -gt 0 ] ; do
        case $1 in
         FOC*)
           wsp="${wsp}%{F${color_head} B${color_wsp}}${sep_right}%{F${color_back} B${color_wsp} T1} ${1#???} %{F${color_wsp} B${color_head}}${sep_right}"
           ;;
         INA*|URG*|ACT*)
           wsp="${wsp}%{F${color_disable} T1} ${1#???} "
           ;;
        esac
        shift
      done
      ;;
    WIN*)
      # window title
      title=$(xprop -id ${line#???} | awk '/_NET_WM_NAME/{$1=$2="";print}' | cut -d'"' -f2)
      title="%{F${color_head} B${color_sec_b2}}${sep_right}%{F${color_head} B${color_sec_b2}%{T2} ${icon_prog} %{F${color_sec_b2} B-}${sep_right}%{F- B- T1} ${title}"
      #title="%{F${color_head} B${color_sec_b2}}${sep_right}%{F${color_head} B${color_sec_b2} T2} ${icon_prog} %{F${color_sec_b2} B-}${sep_right}%{F- B- T1} ${title}"
      ;;
  esac

  # And finally, output
  printf "%s\n" "%{l}${wsp}${title} %{r}${mpd}${stab}${cpu}${stab}${mem}${stab}${wland}${stab}${wlanu}${stab}${vol}${stab}${bat}${stab}${date}${stab}${time}"
  #printf "%s\n" "%{l}${wsp}${title}"
done
