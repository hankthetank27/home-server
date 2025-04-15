import axios from "axios";
import dotenv from 'dotenv';

dotenv.config();

const NAVIDROME_HOST = process.env.NAVIDROME_HOST || '';
const FILEBROWSER_HOST = process.env.FILEBROWSER_HOST || '';

export async function navidromeLogin(username, password) {
  const response = await axios.post(`${NAVIDROME_HOST}/auth/login`, 
    { 
      username, 
      password 
    }, 
    {
      "headers": {
        "Accept": "*/*",
        "Content-Type": "application/json",
      },
    }
  );
  return response.data.token;
}

export async function filebrowserLogin(username, password) {
  const response = await axios.post(`${FILEBROWSER_HOST}/api/login`, 
    { 
      username, 
      password,
      "recaptcha": ""
    }, 
    {
      "headers": {
        "Accept": "*/*",
        "Content-Type": "application/json",
      },
    }
  );
  return response.data;
}

export async function createNavidromeUser(userData, authToken) {
  try {
    const response = await axios.post(`${NAVIDROME_HOST}/api/user`, 
      {
        "isAdmin": false,
        "userName": userData.username,
        "name": userData.username,
        "password": userData.password
      },
      {
        "headers": {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "x-nd-authorization": `Bearer ${authToken}`
        }
      }
    );
    return response
  } catch(e) {
    console.error(`Error creating navidrome user: ${e}`);
    return e.response
  }
}

export async function createFilebrowserUser(userData, authToken) {
  try {
    const response = await axios.post(`${FILEBROWSER_HOST}/api/users`, 
      {
        "what": "user",
        "which": [],
        "data": {
          "scope": "",
          "locale": "en",
          "viewMode": "mosaic",
          "singleClick": false,
          "sorting": {
            "by": "",
            "asc": false
          },
          "perm": {
            "admin": false,
            "execute": true,
            "create": true,
            "rename": true,
            "modify": true,
            "delete": true,
            "share": true,
            "download": true
          },
          "commands": [],
          "hideDotfiles": false,
          "dateFormat": false,
          "username": userData.username,
          "password": userData.password,
          "rules": [],
          "lockPassword": false,
          "id": 0
        }
      },
      {
        "headers": {
          "Accept": "*/*",
          "X-Auth": authToken,
          "Content-Type": "application/json"
        }
      }
    );
    return response
  } catch(e) {
    console.error(`Error creating filebrowser user: ${e}`);
    return e.response
  }
}
