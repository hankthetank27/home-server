import { sendInviteEmail, sendWelcomeEmail } from './email.js';
import { createServerInvite } from './discordInvite.js';
import { 
  createNavidromeUser,
  navidromeLogin,
  filebrowserLogin, 
  createFilebrowserUser
} from './createUser.js'
import { 
  validateInvite,
  createInvite,
  markInviteAsUsed,
  getTokenEmail
} from './inviteStore.js';

export const handlers = {
  generateInvite: async (req, res) => {
    const { email, password, sendEmail } = req.body;

    if (password !== process.env.INVITE_GEN_PW) {
      return res.status(400).json({
        success: false,
        message: 'Invalid password'
      });
    }

    try {
      const token = await createInvite(email);

      if (sendEmail) {
        await sendInviteEmail(email, token);
      }

      res.json({ 
        emailSent: sendEmail,
        success: true,
        token 
      });
    } catch (error) {
      console.error('Error generating invite:', error);
      res.status(500).json({
        success: "failure",
        message: 'An error occurred while generating the invitation'
      });
    }
  },

  validateInvite: async (req, res) => {
    const { token } = req.params;

    try {
      const validation = await validateInvite(token);

      if (!validation.valid) {
        return res.status(400).json({
          success: false,
          message: validation.error
        });
      }

      res.json({
        success: true,
        email: validation.email
      });
    } catch (error) {
      console.error('Error validating invite:', error);
      res.status(500).json({
        success: false,
        message: 'An error occurred while validating the invitation'
      });
    }
  },

  createAccount: async (req, res) => {
    const { username, password, token } = req.body;

    if (token) {
      const validation = await validateInvite(token);
      if (!validation.valid) {
        return res.status(400).json({
          success: false,
          message: validation.error
        });
      }
    }

    if (!username || username.length < 3) {
      return res.status(400).json({
        success: false,
        message: 'Username must be at least 3 characters long'
      });
    }

    if (!password || password.length < 8) {
      return res.status(400).json({
        success: false,
        message: 'Password must be at least 8 characters long'
      });
    }

    try {
      const navidromeToken = await navidromeLogin(
        process.env.ADMIN_UN,
        process.env.ADMIN_PW
      );

      const filebrowserToken = await filebrowserLogin(
        process.env.ADMIN_UN,
        process.env.ADMIN_PW
      );

      const filebrowserUserRes = await createFilebrowserUser({ 
        username,
        password,
      }, filebrowserToken);

      const navidromeUserRes = await createNavidromeUser({ 
        username,
        password,
      }, navidromeToken);

      if (navidromeUserRes.status !== 200 || filebrowserUserRes.status !== 201) {
        if (navidromeUserRes.data?.errors?.userName === 'ra.validation.unique' 
          || filebrowserUserRes.status === 500
        ) {
          return res.status(400).json({
            success: false,
            message: 'Username already exists. Please try a different username.'
          });
        } else {
          throw new Error(
            `Error creating account: filebrowser status: ${filebrowserUserRes.status}, navidrome status: ${navidromeUserRes.status}`
          );
        }
      }

      const discInvite = await createServerInvite(
        process.env.DISCORD_CHANNEL_ID,
        process.env.DISCORD_INVITE_BOT_TOKEN,
      );

      if (token) {
        const emailAddr = await getTokenEmail(token);
        await sendWelcomeEmail(emailAddr, discInvite);
        await markInviteAsUsed(token);
      }

      res.json({ 
        success: true,
        url: process.env.APP_URL,
        discInvite,
      });
    } catch (error) {
      console.error("Error creating account: ", error);
      res.status(500).json({
        success: "failure",
        message: 'An error occurred while creating the account'
      });
    }
  },
};

