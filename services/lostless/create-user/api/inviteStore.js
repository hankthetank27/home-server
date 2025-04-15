import crypto from 'crypto';
import fs from 'fs/promises';
import path from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const INVITES_FILE = path.join(__dirname, '../invite-data/invites.json');

const ensureDataDir = async () => {
  const dataDir = path.join(__dirname, '../invite-data');
  try {
    await fs.access(dataDir);
  } catch (error) {
    await fs.mkdir(dataDir, { recursive: true });
  }
  
  try {
    await fs.access(INVITES_FILE);
  } catch (error) {
    await fs.writeFile(INVITES_FILE, JSON.stringify({}));
  }
};

const loadInvites = async () => {
  await ensureDataDir();
  const data = await fs.readFile(INVITES_FILE, 'utf8');
  return JSON.parse(data);
};

const saveInvites = async (invites) => {
  await ensureDataDir();
  await fs.writeFile(INVITES_FILE, JSON.stringify(invites, null, 2));
};

const generateToken = () => {
  return crypto.randomBytes(32).toString('hex');
};

export const createInvite = async (email) => {
  const token = generateToken();
  const invites = await loadInvites();
  
  invites[token] = {
    email,
    created: new Date().toISOString(),
    used: false
  };
  
  await saveInvites(invites);
  return token;
};

export const validateInvite = async (token) => {
  const invites = await loadInvites();
  
  if (!invites[token]) {
    return { valid: false, error: 'Invalid invitation token' };
  }
  
  if (invites[token].used) {
    return { valid: false, error: 'This invitation has already been used' };
  }
  
  return { 
    valid: true, 
    email: invites[token].email 
  };
};

export const markInviteAsUsed = async (token) => {
  const invites = await loadInvites();
  if (invites[token]) {
    invites[token].used = true;
    invites[token].usedAt = new Date().toISOString();
    await saveInvites(invites);
    return true;
  }
  
  return false;
};

export const getTokenEmail = async (token) => {
  const invites = await loadInvites();
  return invites[token].email;
};
