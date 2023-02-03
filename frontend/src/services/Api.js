// constants
const URL = process.env.REACT_APP_API_URL || "http://localhost:4000";

const DEFAULT_HEADERS = {
  "Content-Type": "application/json",
};

const METHODS = {
  get: "GET",
  post: "POST",
  patch: "PATCH",
  put: "PUT",
};

const ROUTES = {
  getPresignedUrl: "/api/v1/get_presigned_url",
};

// default functions

async function request({method, path, body, headers}) {
  const response = await fetch(URL + path, {
    method,
    body: JSON.stringify(body),
    headers: Object.assign(DEFAULT_HEADERS, headers),
  });
  const {status, url, ok} = response;
  if (status === 204) {
    body = {};
  } else {
    body = await response.json();
  }
  return {body: body, status, url, ok};
}

// calls

async function getPresignedUrl() {
  return request({method: METHODS.post, path: ROUTES.getPresignedUrl});
}

const api = {
  getPresignedUrl,
};

export default api;
