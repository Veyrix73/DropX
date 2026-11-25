import React, { useEffect, useRef, useState } from "react";
import {
  Alert,
  Animated,
  Pressable,
  SafeAreaView,
  ScrollView,
  StatusBar,
  StyleSheet,
  Switch,
  Text,
  TextInput,
  View,
} from "react-native";
import * as DocumentPicker from "expo-document-picker";
import { LinearGradient } from "expo-linear-gradient";

type Tab = "send" | "activity" | "settings";
type PickedAsset = DocumentPicker.DocumentPickerAsset;

const ACCENTS = [
  { name: "Lime", value: "#B9E66A" },
  { name: "Coral", value: "#FF8061" },
  { name: "Honey", value: "#EABD59" },
  { name: "Mint", value: "#81C9A7" },
];

function formatSize(bytes?: number) {
  if (bytes === undefined) return "Size unavailable";
  if (bytes < 1024) return bytes + " B";
  if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(0) + " KB";
  return (bytes / (1024 * 1024)).toFixed(1) + " MB";
}

export default function App() {
  const [tab, setTab] = useState<Tab>("send");
  const [files, setFiles] = useState<PickedAsset[]>([]);
  const [code, setCode] = useState("");
  const [darkMode, setDarkMode] = useState(false);
  const [animations, setAnimations] = useState(true);
  const [accent, setAccent] = useState(ACCENTS[0].value);
  const [picking, setPicking] = useState(false);

  const fade = useRef(new Animated.Value(1)).current;
  const float = useRef(new Animated.Value(0)).current;

  const colors = darkMode
    ? {
        background: "#202820",
        surface: "#2B352C",
        surfaceAlt: "#354137",
        text: "#F4F3E9",
        muted: "#AEB9A9",
        border: "#465244",
        input: "#303B31",
      }
    : {
        background: "#F4F4EC",
        surface: "#FFFFFF",
        surfaceAlt: "#EBEEE3",
        text: "#273127",
        muted: "#778174",
        border: "#E4E8DC",
        input: "#F5F6F0",
      };

  useEffect(() => {
    if (!animations) {
      float.setValue(0);
      return;
    }
    const loop = Animated.loop(
      Animated.sequence([
        Animated.timing(float, {
          toValue: 1,
          duration: 2600,
          useNativeDriver: true,
        }),
        Animated.timing(float, {
          toValue: 0,
          duration: 2600,
          useNativeDriver: true,
        }),
      ])
    );
    loop.start();
    return () => loop.stop();
  }, [animations, float]);

  const floatY = float.interpolate({
    inputRange: [0, 1],
    outputRange: [0, -10],
  });

  const changeTab = (next: Tab) => {
    if (next === tab) return;
    Animated.timing(fade, {
      toValue: 0,
      duration: animations ? 100 : 0,
      useNativeDriver: true,
    }).start(() => {
      setTab(next);
      Animated.timing(fade, {
        toValue: 1,
        duration: animations ? 190 : 0,
        useNativeDriver: true,
      }).start();
    });
  };

  const chooseFiles = async () => {
    try {
      setPicking(true);
      const result = await DocumentPicker.getDocumentAsync({
        type: "*/*",
        multiple: true,
        copyToCacheDirectory: true,
      });
      if (!result.canceled) {
        setFiles((current) => [...current, ...result.assets]);
      }
    } catch {
      Alert.alert("Could not open files", "Please try choosing your files again.");
    } finally {
      setPicking(false);
    }
  };

  const showPairingNotice = () => {
    Alert.alert(
      "Pairing is coming next",
      "This preview can select files, but device pairing and real transfers are not connected yet."
    );
  };

  const content = () => {
    if (tab === "activity") {
      return (
        <View style={s.page}>
          <Text style={[s.eyebrow, { color: colors.muted }]}>YOUR SHARING HISTORY</Text>
          <Text style={[s.pageTitle, { color: colors.text }]}>Activity</Text>
          <Text style={[s.body, { color: colors.muted }]}>
            Your recent transfers will show up here.
          </Text>
          <View style={[s.emptyCard, { backgroundColor: colors.surface, borderColor: colors.border }]}>
            <View style={[s.emptyIcon, { backgroundColor: colors.surfaceAlt }]}>
              <Text style={{ fontSize: 27 }}>↗</Text>
            </View>
            <Text style={[s.cardTitle, { color: colors.text }]}>Nothing shared yet</Text>
            <Text style={[s.body, { color: colors.muted, textAlign: "center" }]}>
              Once transfers are connected, you will find sent and received files here.
            </Text>
            <Pressable onPress={() => changeTab("send")} style={[s.primaryButton, { backgroundColor: accent }]}>
              <Text style={s.primaryButtonText}>Start sharing</Text>
              <Text style={s.buttonArrow}>↗</Text>
            </Pressable>
          </View>
        </View>
      );
    }

    if (tab === "settings") {
      return (
        <View style={s.page}>
          <Text style={[s.eyebrow, { color: colors.muted }]}>MAKE IT YOURS</Text>
          <Text style={[s.pageTitle, { color: colors.text }]}>Settings</Text>
          <Text style={[s.body, { color: colors.muted }]}>A few little details, exactly your way.</Text>

          <View style={[s.settingsCard, { backgroundColor: colors.surface, borderColor: colors.border }]}>
            <View style={s.settingRow}>
              <View style={s.settingCopy}>
                <Text style={[s.cardTitle, { color: colors.text }]}>Dark appearance</Text>
                <Text style={[s.smallBody, { color: colors.muted }]}>Use a deeper interface</Text>
              </View>
              <Switch value={darkMode} onValueChange={setDarkMode} trackColor={{ false: colors.border, true: accent }} />
            </View>
            <View style={[s.separator, { backgroundColor: colors.border }]} />
            <View style={s.settingRow}>
              <View style={s.settingCopy}>
                <Text style={[s.cardTitle, { color: colors.text }]}>Motion effects</Text>
                <Text style={[s.smallBody, { color: colors.muted }]}>Enable subtle animations</Text>
              </View>
              <Switch value={animations} onValueChange={setAnimations} trackColor={{ false: colors.border, true: accent }} />
            </View>
          </View>

          <Text style={[s.sectionLabel, { color: colors.muted }]}>ACCENT COLOUR</Text>
          <View style={[s.settingsCard, { backgroundColor: colors.surface, borderColor: colors.border }]}>
            <View style={s.swatches}>
              {ACCENTS.map((item) => (
                <Pressable
                  accessibilityRole="button"
                  accessibilityLabel={item.name + " accent"}
                  key={item.name}
                  onPress={() => setAccent(item.value)}
                  style={[
                    s.swatch,
                    { backgroundColor: item.value },
                    accent === item.value && s.swatchSelected,
                  ]}
                >
                  {accent === item.value ? <Text style={s.swatchCheck}>✓</Text> : null}
                </Pressable>
              ))}
            </View>
          </View>
          <Text style={[s.footnote, { color: colors.muted }]}>
            Preferences are currently kept in this preview session. Saving them between launches comes later.
          </Text>
        </View>
      );
    }

    return (
      <View style={s.page}>
        <View style={s.topLine}>
          <View>
            <Text style={[s.eyebrow, { color: colors.muted }]}>SHARE YOUR WORLD</Text>
            <Text style={[s.pageTitle, { color: colors.text }]}>Files, minus{ "\n" }the fuss.</Text>
          </View>
          <View style={[s.readyPill, { backgroundColor: colors.surface, borderColor: colors.border }]}>
            <View style={[s.readyDot, { backgroundColor: accent }]} />
            <Text style={[s.readyText, { color: colors.muted }]}>PREVIEW</Text>
          </View>
        </View>
        <Text style={[s.body, { color: colors.muted, marginTop: 10, marginBottom: 22 }]}>
          A simpler way to move things between your devices.
        </Text>

        <LinearGradient
          colors={[accent, "#E7F0C8"]}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 1 }}
          style={s.hero}
        >
          <Animated.View style={[s.heroOrb, { transform: [{ translateY: floatY }] }]} />
          <View style={s.heroTop}>
            <View style={s.heroTag}><Text style={s.heroTagText}>DROPX / 01</Text></View>
            <Text style={s.heroSymbol}>↗</Text>
          </View>
          <Text style={s.heroTitle}>Send it.{ "\n" }Simply.</Text>
          <Text style={s.heroDescription}>Pick your files. The rest should feel effortless.</Text>
          <Pressable onPress={chooseFiles} disabled={picking} style={({ pressed }) => [s.heroButton, pressed && s.pressed]}>
            <Text style={s.heroButtonText}>{picking ? "Opening files…" : "Choose files"}</Text>
            <Text style={s.heroButtonArrow}>↗</Text>
          </Pressable>
          <Text style={s.heroHint}>PHOTOS  ·  DOCUMENTS  ·  MORE</Text>
        </LinearGradient>

        {files.length > 0 ? (
          <View style={[s.fileCard, { backgroundColor: colors.surface, borderColor: colors.border }]}>
            <View style={s.fileCardHeader}>
              <View>
                <Text style={[s.cardTitle, { color: colors.text }]}>Selected files</Text>
                <Text style={[s.smallBody, { color: colors.muted }]}>{files.length} item{files.length === 1 ? "" : "s"} ready</Text>
              </View>
              <Pressable onPress={() => setFiles([])}><Text style={[s.clearText, { color: colors.muted }]}>Clear</Text></Pressable>
            </View>
            {files.slice(0, 3).map((file, index) => (
              <View key={file.uri + index} style={s.fileRow}>
                <View style={[s.fileIcon, { backgroundColor: colors.surfaceAlt }]}><Text style={{ fontSize: 17 }}>▤</Text></View>
                <View style={{ flex: 1 }}>
                  <Text numberOfLines={1} style={[s.fileName, { color: colors.text }]}>{file.name}</Text>
                  <Text style={[s.smallBody, { color: colors.muted }]}>{formatSize(file.size)}</Text>
                </View>
              </View>
            ))}
            {files.length > 3 ? <Text style={[s.smallBody, { color: colors.muted, marginTop: 8 }]}>+ {files.length - 3} more</Text> : null}
            <View style={[s.notice, { backgroundColor: colors.surfaceAlt }]}>
              <Text style={[s.noticeText, { color: colors.muted }]}>Files are selected on this device. Sending starts after pairing is built.</Text>
            </View>
          </View>
        ) : null}

        <View style={[s.receiveCard, { backgroundColor: colors.surface, borderColor: colors.border }]}>
          <View style={s.receiveHeader}>
            <View style={[s.receiveIcon, { backgroundColor: colors.surfaceAlt }]}><Text style={{ fontSize: 20 }}>⌗</Text></View>
            <View style={{ flex: 1 }}>
              <Text style={[s.cardTitle, { color: colors.text }]}>Receive files</Text>
              <Text style={[s.smallBody, { color: colors.muted }]}>Have a sharing code?</Text>
            </View>
            <Text style={[s.nextArrow, { color: colors.muted }]}>↘</Text>
          </View>
          <View style={s.codeRow}>
            <TextInput
              value={code}
              onChangeText={(value) => setCode(value.replace(/[^0-9]/g, "").slice(0, 6))}
              keyboardType="number-pad"
              maxLength={6}
              placeholder="000 000"
              placeholderTextColor={colors.muted}
              style={[s.codeInput, { color: colors.text, backgroundColor: colors.input, borderColor: colors.border }]}
            />
            <Pressable onPress={showPairingNotice} style={[s.joinButton, { backgroundColor: colors.text }]}>
              <Text style={[s.joinButtonText, { color: colors.surface }]}>Join</Text>
            </Pressable>
          </View>
          <Text style={[s.footnote, { color: colors.muted }]}>Pairing is the next feature being built.</Text>
        </View>
      </View>
    );
  };

  return (
    <SafeAreaView style={[s.safe, { backgroundColor: colors.background }]}>
      <StatusBar barStyle={darkMode ? "light-content" : "dark-content"} />
      <View style={s.appHeader}>
        <View style={s.brand}>
          <View style={[s.logo, { backgroundColor: accent }]}>
            <Text style={s.logoText}>D</Text>
            <View style={s.logoDot} />
          </View>
          <Text style={[s.brandName, { color: colors.text }]}>dropx</Text>
        </View>
        <View style={[s.avatar, { backgroundColor: colors.surfaceAlt, borderColor: colors.border }]}>
          <Text style={[s.avatarText, { color: colors.text }]}>DX</Text>
        </View>
      </View>

      <Animated.View style={{ flex: 1, opacity: fade }}>
        <ScrollView
          contentContainerStyle={s.scrollContent}
          showsVerticalScrollIndicator={false}
        >
          {content()}
        </ScrollView>
      </Animated.View>

      <View style={[s.tabBar, { backgroundColor: colors.surface, borderColor: colors.border }]}>
        {([
          { key: "send", label: "Send", icon: "↗" },
          { key: "activity", label: "Activity", icon: "◷" },
          { key: "settings", label: "Settings", icon: "⚙" },
        ] as const).map((item) => {
          const active = tab === item.key;
          return (
            <Pressable key={item.key} onPress={() => changeTab(item.key)} style={s.tabItem}>
              <View style={[s.tabIconWrap, active && { backgroundColor: accent }]}>
                <Text style={[s.tabIcon, { color: active ? "#263020" : colors.muted }]}>{item.icon}</Text>
              </View>
              <Text style={[s.tabLabel, { color: active ? colors.text : colors.muted }]}>{item.label}</Text>
            </Pressable>
          );
        })}
      </View>
    </SafeAreaView>
  );
}

const s = StyleSheet.create({
  safe: { flex: 1 },
  appHeader: {
    paddingHorizontal: 22,
    paddingTop: 10,
    paddingBottom: 12,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
  },
  brand: { flexDirection: "row", alignItems: "center", gap: 10 },
  logo: {
    width: 34,
    height: 34,
    borderRadius: 12,
    alignItems: "center",
    justifyContent: "center",
    position: "relative",
  },
  logoText: { color: "#273127", fontWeight: "900", fontSize: 17 },
  logoDot: { position: "absolute", width: 6, height: 6, borderRadius: 3, backgroundColor: "#FFFFFF", right: 6, top: 6 },
  brandName: { fontSize: 21, fontWeight: "800", letterSpacing: -0.8 },
  avatar: { width: 36, height: 36, borderRadius: 18, borderWidth: 1, alignItems: "center", justifyContent: "center" },
  avatarText: { fontSize: 10, fontWeight: "800", letterSpacing: 0.4 },
  scrollContent: { paddingBottom: 24 },
  page: { paddingHorizontal: 22, paddingTop: 20, gap: 13 },
  topLine: { flexDirection: "row", alignItems: "flex-start", justifyContent: "space-between" },
  eyebrow: { fontSize: 10, fontWeight: "800", letterSpacing: 1.8, marginBottom: 9 },
  pageTitle: { fontSize: 36, lineHeight: 39, fontWeight: "800", letterSpacing: -1.5 },
  body: { fontSize: 14, lineHeight: 21 },
  readyPill: { marginTop: 4, borderWidth: 1, borderRadius: 20, paddingHorizontal: 10, paddingVertical: 7, flexDirection: "row", alignItems: "center", gap: 6 },
  readyDot: { width: 6, height: 6, borderRadius: 3 },
  readyText: { fontSize: 9, fontWeight: "800", letterSpacing: 1 },
  hero: { minHeight: 275, padding: 22, borderRadius: 27, overflow: "hidden" },
  heroOrb: { position: "absolute", width: 190, height: 190, borderRadius: 95, backgroundColor: "#FFFFFF", opacity: 0.22, right: -45, top: 36 },
  heroTop: { flexDirection: "row", alignItems: "center", justifyContent: "space-between" },
  heroTag: { borderRadius: 20, backgroundColor: "rgba(255,255,255,0.42)", paddingHorizontal: 10, paddingVertical: 6 },
  heroTagText: { color: "#34402B", fontSize: 9, letterSpacing: 1.2, fontWeight: "800" },
  heroSymbol: { fontSize: 26, color: "#34402B", fontWeight: "600" },
  heroTitle: { fontSize: 39, lineHeight: 40, fontWeight: "900", letterSpacing: -1.8, color: "#263020", marginTop: 21 },
  heroDescription: { fontSize: 13, lineHeight: 19, color: "#4F5B43", maxWidth: 220, marginTop: 8 },
  heroButton: { backgroundColor: "#263020", alignSelf: "flex-start", borderRadius: 15, paddingHorizontal: 16, paddingVertical: 13, marginTop: 18, flexDirection: "row", alignItems: "center", gap: 22 },
  heroButtonText: { color: "#FFFFFF", fontWeight: "700", fontSize: 13 },
  heroButtonArrow: { color: "#FFFFFF", fontSize: 15 },
  heroHint: { color: "#4F5B43", fontSize: 8, fontWeight: "800", letterSpacing: 1.3, marginTop: 13 },
  fileCard: { borderWidth: 1, borderRadius: 22, padding: 17, marginTop: 1 },
  fileCardHeader: { flexDirection: "row", justifyContent: "space-between", alignItems: "center", marginBottom: 12 },
  cardTitle: { fontSize: 15, fontWeight: "800", letterSpacing: -0.2 },
  smallBody: { fontSize: 11, lineHeight: 16 },
  clearText: { fontSize: 12, fontWeight: "700" },
  fileRow: { flexDirection: "row", alignItems: "center", gap: 11, paddingVertical: 8 },
  fileIcon: { width: 37, height: 37, borderRadius: 12, alignItems: "center", justifyContent: "center" },
  fileName: { fontSize: 12, fontWeight: "700" },
  notice: { borderRadius: 11, padding: 10, marginTop: 10 },
  noticeText: { fontSize: 10, lineHeight: 15 },
  receiveCard: { borderWidth: 1, borderRadius: 22, padding: 17, marginTop: 2 },
  receiveHeader: { flexDirection: "row", alignItems: "center", gap: 11, marginBottom: 14 },
  receiveIcon: { width: 42, height: 42, borderRadius: 14, alignItems: "center", justifyContent: "center" },
  nextArrow: { fontSize: 18 },
  codeRow: { flexDirection: "row", gap: 9 },
  codeInput: { flex: 1, height: 48, borderRadius: 13, borderWidth: 1, paddingHorizontal: 14, fontSize: 17, fontWeight: "700", letterSpacing: 3 },
  joinButton: { minWidth: 76, borderRadius: 13, alignItems: "center", justifyContent: "center" },
  joinButtonText: { fontWeight: "800", fontSize: 13 },
  footnote: { fontSize: 10, lineHeight: 15, marginTop: 10 },
  emptyCard: { borderWidth: 1, borderRadius: 24, alignItems: "center", padding: 25, marginTop: 15, gap: 12 },
  emptyIcon: { width: 58, height: 58, borderRadius: 20, alignItems: "center", justifyContent: "center", marginBottom: 4 },
  primaryButton: { borderRadius: 14, paddingHorizontal: 17, paddingVertical: 13, flexDirection: "row", alignItems: "center", gap: 17, marginTop: 7 },
  primaryButtonText: { color: "#273127", fontWeight: "800", fontSize: 13 },
  buttonArrow: { color: "#273127", fontSize: 16 },
  settingsCard: { borderWidth: 1, borderRadius: 22, padding: 18, marginTop: 8 },
  settingRow: { flexDirection: "row", alignItems: "center", justifyContent: "space-between", gap: 12, paddingVertical: 4 },
  settingCopy: { flex: 1, gap: 4 },
  separator: { height: 1, marginVertical: 14 },
  sectionLabel: { fontSize: 10, letterSpacing: 1.6, fontWeight: "800", marginTop: 15, marginBottom: -5 },
  swatches: { flexDirection: "row", alignItems: "center", gap: 15 },
  swatch: { width: 43, height: 43, borderRadius: 16, alignItems: "center", justifyContent: "center" },
  swatchSelected: { borderWidth: 3, borderColor: "#34402B" },
  swatchCheck: { color: "#273127", fontWeight: "900", fontSize: 17 },
  pressed: { opacity: 0.86, transform: [{ scale: 0.985 }] },
  tabBar: {
    marginHorizontal: 16,
    marginBottom: 8,
    borderRadius: 22,
    borderWidth: 1,
    paddingVertical: 8,
    paddingHorizontal: 7,
    flexDirection: "row",
    justifyContent: "space-around",
  },
  tabItem: { flex: 1, alignItems: "center", gap: 3, paddingVertical: 2 },
  tabIconWrap: { width: 37, height: 30, borderRadius: 12, alignItems: "center", justifyContent: "center" },
  tabIcon: { fontSize: 18, fontWeight: "700" },
  tabLabel: { fontSize: 10, fontWeight: "700" },
});
