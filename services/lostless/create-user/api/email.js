import nodemailer from 'nodemailer';

function createTransporter() {
  return nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_APP_PASSWORD
    }
  });
}

export async function sendInviteEmail(email, token) {
  const transporter = createTransporter();
  const inviteUrl = `${process.env.APP_URL || 'http://localhost:3000'}/invite/${token}`;
  const mailOptions = {
    from: process.env.EMAIL_USER,
    to: email,
    subject: "lostless.cafe invite",
    text: `Hi and welcome to lostless.cafe! To create an account please click the link below:\n\n${inviteUrl}\n\nThis link can only be used once.`,
    html: `
      <div style="font-family: Arial, sans-serif; margin: 0 auto; padding: 5px; border-radius: 5px;">
        <p>Hi and welcome to lostless.cafe -- a small, privately hosted music streaming and file sharing network for some friends to share cool music they like and have an easy way to listen to and download it.</p> 
        <p>To create an account and get more info please click the link below...</p>
        <p><a href="${inviteUrl}">Create your account</a></p>
        <p>Cheers,</p>
        <p>Hank</p>
        <img src="https://signup.lostless.cafe/welcome.png" style="width: 180px;">
      </div>
    `,
  };
  try {
    const info = await transporter.sendMail(mailOptions);
    console.log('Invitation email sent successfully');
    console.log('Message ID:', info.messageId);
    return info;
  } catch (error) {
    console.error('Error sending invitation email:', error);
    throw error;
  }
}

export async function sendWelcomeEmail(email, discordInvite) {
  const transporter = createTransporter();
  const mailOptions = {
    from: process.env.EMAIL_USER,
    to: email,
    subject: "Welcome to lostless.cafe!",
    html: `
      <div>
        <h3>Hi and welcome to lostless.cafe!</h3>
        <p>lostless.cafe is a small, privately hosted music streaming and file sharing network for some friends to share cool music they like and have an easy way to listen to or download it. Users can upload music which is then available for all other users in the network to listen to, make playlists with (public or private), download, etc - all via the streaming platform. The services and all data (audio and beyond) is self hosted by a machine in my apartment and operates mostly independently from cloud infrastructure, so please excuse any slowness or other issues!</p>
        <p>To listen to music on lostless.cafe you can login at <a href="https://lostless.cafe/">https://lostless.cafe/</a>.</p>
        <p>To upload music to lostless.cafe you can login at <a href="https://upload.lostless.cafe/">https://upload.lostless.cafe/</a>.</p>
        <p>Please consider joining the <a href="https://discord.gg/${discordInvite}">Discord channel</a> for updates and to chat with the other users.</p>
        <p>Both the upload and streaming pages should be pretty self explanatory, but If you get lost or have any questions let me know!</p>
        <p>You can also access the streaming portion on mobile (or desktop for that matter) from an App. Any <a href="https://subsonic.org/pages/apps.jsp">listed here</a> will work. All you have to do is download the app, and then add the streaming url and your user credentials to it and you should be good to go. Personally, I have play:Sub setup on my iPhone and it works very nicely.</p>
        <p>This is a completely new project and I'm completely open to any feedback you might have, so please do not hesitate to reach out with ideas, critiques, or really any thoughts at all.</p>
        <hr/>
        <h3>Some points and guidelines</h3>
          <h4>Uploading</h4>
        <p><strong>All uploads must contain at LEAST Artist, Title, and Album metadata!</strong> Any files that do not contain this information, are detected and automatically deleted! This is a minimum requirement, and if you could please include things like album artwork as well that would be very much appreciated.</p>
        <p>The server has a limited amount of disk space (14tb at the time of writing this), and I spent a long time deliberating how to maximize the usage of it without sacrificing too much audio quality on uploads. I figured that the most effective way of dealing with this problem is to have any lossless files automatically be compressed to a .flac file, so this is what happens. Flac has the nice property of compressing to about half as much space as other lossless file types without degrading the quality or losing any information in the process. I know people find flac annoying because it's not widely supported. Sorry, this is just the best I could come up with for now and you can always unpack flacs into a .aiff or whatever.</p>
          <h4>Streaming</h4>
        <p>When making public playlists, consider prefixing the title of it with your username! You don't need to, but there is no way for users to see others' activity (or who "owns" a playlist), so if you care about anyone knowing you made the playlist you should put your name in it.</p>
        <hr/>
        <h3>some random technical stuff for nerds</h3>
        <p>If you're a nerd and care about things like how this works you can check out the system config and scripts that power it <a href="https://github.com/hankthetank27/lostless-cafe-server">here</a>.</p>
        <p>lostless.cafe exists thanks to some cool open source projects, <a href="https://www.navidrome.org/">navidrome</a> and <a href="https://filebrowser.org/">filebrowser</a>. So big shouts out to the people who maintain them both.</p>
      </div>
    `
  };
  try {
    const info = await transporter.sendMail(mailOptions);
    console.log('Welcome email sent successfully');
    console.log('Message ID:', info.messageId);
    return info;
  } catch (error) {
    console.error('Error sending Welcome email:', error);
  }
}
