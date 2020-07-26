#TODO
# - version checks before updating

update_check(){
  read_local_commit
  read_remote_commit
}

update_kiauh(){
  if [ $KIAUH_UPDATE_AVAIL = 1 ]; then
    status_msg "Updating KIAUH ..."
    cd ${HOME}/kiauh
    git pull && ok_msg "Update complete! Please restart KIAUH."; echo
  fi
}

update_klipper(){
  stop_klipper
  if [ ! -d $KLIPPER_DIR ]; then
    cd ${HOME} && git clone $KLIPPER_REPO
  else
    bb4u "klipper"
    read_branch
    save_klipper_state
    status_msg "Updating $GET_BRANCH"
    #fetching origin/master -> error
    #rewriting origin/master to origin
    if [ "$GET_BRANCH" == "origin/master" ]; then
      FETCH_BRANCH="origin"
    else
      FETCH_BRANCH=$(echo "$GET_BRANCH" | cut -d "/" -f1)
    fi
    status_msg "Fetching from $FETCH_BRANCH"
    git fetch $FETCH_BRANCH -q && ok_msg "Fetch successfull!"
    status_msg "Checking out $GET_BRANCH"
    git checkout $GET_BRANCH -q && ok_msg "Checkout successfull!" && echo; ok_msg "Update complete!"
  fi
  start_klipper; echo
}

update_dwc2fk(){
  stop_klipper
  bb4u "dwc2"
  if [ ! -d $DWC2FK_DIR ]; then
    cd ${HOME} && git clone $DWC2FK_REPO
  else
    cd $DWC2FK_DIR && git pull
    #create a web_dwc2.py symlink if not already existing
    if [ -d $KLIPPER_DIR/klippy/extras ] && [ ! -e $WEB_DWC2 ]; then
      status_msg "Creating web_dwc2.py Symlink ..."
      ln -s $DWC2FK_DIR/web_dwc2.py $WEB_DWC2 && ok_msg "Symlink created!"
    fi
  fi
  start_klipper
}

update_dwc2(){
  bb4u "dwc2"
  install_dwc2
}

update_mainsail(){
  stop_klipper
  bb4u "mainsail"
  status_msg "Updating Mainsail ..."
  install_mainsail
  start_klipper
}

save_klipper_state(){
  source_ini
  #read current klipper state
  COMMIT_STATE=$(git rev-parse --short HEAD)
  if [ $GET_BRANCH = origin/master ]; then
    ORI_OLD=$previous_origin_state
    ORI_NEW=$COMMIT_STATE
    sed -i "/previous_origin_state=/s/$ORI_OLD/$ORI_NEW/" $INI_FILE
  elif [ $GET_BRANCH = dmbutyugin/scurve-shaping ]; then
    SHA_OLD=$previous_shaping_state
    SHA_NEW=$COMMIT_STATE
    sed -i "/previous_shaping_state=/s/$SHA_OLD/$SHA_NEW/" $INI_FILE
  elif [ $GET_BRANCH = dmbutyugin/scurve-smoothing ]; then
    SMO_OLD=$previous_smoothing_state
    SMO_NEW=$COMMIT_STATE
    sed -i "/previous_smoothing_state=/s/$SMO_OLD/$SMO_NEW/" $INI_FILE
  elif [ $GET_BRANCH = Arksine/work-web_server-20200131 ]; then
    WWS_OLD=$previous_moonraker_state
    WWS_NEW=$COMMIT_STATE
    sed -i "/previous_moonraker_state=/s/$WWS_OLD/$WWS_NEW/" $INI_FILE
  elif [ $GET_BRANCH = Arksine/dev-moonraker-testing ]; then
    DMT_OLD=$previous_dev_moonraker_state
    DMT_NEW=$COMMIT_STATE
    sed -i "/previous_dev_moonraker_state=/s/$DMT_OLD/$DMT_NEW/" $INI_FILE
  fi
}