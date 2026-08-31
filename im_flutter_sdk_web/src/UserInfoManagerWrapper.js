/** Web 5.0 UserInfoManager adapter. */
export function createUserInfoManagerWrapper({ manager, currentUser, h }) {
  const commands = {
    fetchOwnInfo: async (m) => {
      const profiles = await m.getUserInfoByUserId({ userIds: [currentUser()] });
      return h.normalizeUserInfoProfile(
        profiles.find((profile) => String(profile?.userId || "") === currentUser()) || null,
      );
    },
    fetchSubscribedUsers: (m) => m.getSubscribedUsers(),
    fetchUserInfoById: async (m, i) => {
      const ids = h.userIds(i);
      return h.userInfoMap(await m.getUserInfoByUserId({ userIds: ids }), ids);
    },
    fetchUserInfoByIdWithType: async (m, i) => {
      const ids = h.userIds(i);
      return h.userInfoMap(await m.getUserInfoByAttribute({ userIds: ids, attributes: h.userInfoAttributes(i) }), ids);
    },
    getUserInfoWithUserId: async (m, i) => {
      const id = h.userId(i);
      const profiles = await m.getUserInfoByUserId({ userIds: [id] });
      return h.normalizeUserInfoProfile(
        profiles.find((profile) => String(profile?.userId || "") === id) || null,
      );
    },
    getUserInfoWithUserIds: async (m, i) => {
      const ids = h.userIds(i);
      return h.userInfoMap(await m.getUserInfoByUserId({ userIds: ids }), ids);
    },
    subscribeUsersInfo: (m, i) => m.subscribeUsersInfo({ userIds: i.userIds || [], expires: i.expires }),
    unsubscribeUsersInfo: (m, i) => m.unsubscribeUsersInfo({ userIds: i.userIds || [] }),
    updateOwnUserInfo: async (m, i) => h.normalizeUserInfoProfile(
      await m.updateOwnInfo(h.normalizeUserInfoInput(i.userInfo || i.info || i)),
    ),
    updateOwnUserInfoWithType: async (m, i) => JSON.stringify(
      h.normalizeUserInfoForTypeResult(
        await m.updateOwnInfoByAttribute(h.userInfoAttribute(i.userInfoType ?? i.type), i.userInfoValue),
      ),
    ),
  };

  return { commands };
}
