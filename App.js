/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow strict-local
 */

import React, {useEffect, useState} from 'react';
import type {Node} from 'react';
import {
  SafeAreaView,
  StatusBar,
  StyleSheet,
  Text,
  useColorScheme,
  View,
  NativeModules,
  Platform,
} from 'react-native';

import {Colors} from 'react-native/Libraries/NewAppScreen';

/* $FlowFixMe[missing-local-annot] The type annotation(s) required by Flow's
 * LTI update could not be added via codemod */

const App: () => Node = () => {
  const isDarkMode = useColorScheme() === 'dark';
  const DeviceInfo = NativeModules.DeviceInfoGet;

  const backgroundStyle = {
    backgroundColor: isDarkMode ? Colors.darker : Colors.lighter,
  };

  const [state, setState] = useState();
  const [storage, setStorage] = useState('');

  useEffect(() => {
    getDeviceStorage();
    getDeviceModel();
  }, []);

  const getDeviceStorage = async () => {
    const freeStorage = DeviceInfo.getFreeDiskStorage();
    const totalStorage = DeviceInfo.getTotalDiskCapacity();
    let resp = await Promise.all([freeStorage, totalStorage]);
    const result = (100 * resp[0]) / resp[1];
    setStorage(`${Math.round(100 - result)} % used`);
  };

  const getDeviceModel = () => {
    setState({
      deviceId: DeviceInfo?.deviceId,
      model: DeviceInfo?.model,
      brand: DeviceInfo?.brand,
      systemName: DeviceInfo?.systemName,
      systemVersion: DeviceInfo?.systemVersion,
    });
  };

  return (
    <SafeAreaView>
      <StatusBar
        barStyle={isDarkMode ? 'light-content' : 'dark-content'}
        backgroundColor={backgroundStyle.backgroundColor}
      />
      <View style={styles.header}>
        <Text style={styles.headerText}>My Device Info</Text>
      </View>
      <View style={styles.container}>
        <View style={styles.section}>
          <Text style={[styles.infoText, {fontWeight: 'bold'}]}>
            {state?.brand}{' '}
            {Platform.OS === 'ios' ? state?.deviceId : state?.model}
          </Text>
          <Text style={styles.infoText}>
            {state?.systemName} {state?.systemVersion}
          </Text>
        </View>

        <View style={styles.section}>
          <Text style={[styles.infoText, {fontWeight: 'bold'}]}>
            Internal Storage
          </Text>
          <Text style={styles.infoText}>{storage}</Text>
        </View>
      </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  header: {
    justifyContent: 'center',
    alignItems: 'center',
    paddingVertical: 20,
    borderBottomWidth: 1,
  },
  container: {
    justifyContent: 'center',
    alignItems: 'center',
    paddingVertical: 20,
  },
  headerText: {
    fontSize: 18,
    // color: 'red',
  },
  infoText: {
    fontSize: 20,
    textAlign: 'center',
  },
  section: {
    marginTop: 20,
    marginBottom: 20,
  },
});

export default App;
