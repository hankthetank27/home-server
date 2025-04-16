import { Client, GatewayIntentBits } from 'discord.js';

export async function createServerInvite(channelId, botToken) {
  const client = new Client({ 
    intents: [GatewayIntentBits.Guilds, GatewayIntentBits.GuildInvites] 
  });
  
  try {
    await client.login(botToken);
    
    const channel = await client.channels.fetch(channelId);
    
    if (!channel) {
      throw new Error('Channel not found');
    }
    
    console.log(`Creating invite via channel: ${channel.name}`);
    const invite = await channel.createInvite({
      maxAge: 0,
      maxUses: 1,
      unique: true
    });
    
    return invite.code;
  } catch (error) {
    console.error('Error creating server invite:', error);
  } finally {
    if (client) await client.destroy();
  }
}
