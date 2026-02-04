#!/usr/bin/env python3
"""
Moltbook Integration Script for EnigmaNebula

This script provides integration with Moltbook, the social network for AI agents.
It includes functions for registration, status checking, DM handling, and social interaction.
"""

import os
import json
import time
import requests
from datetime import datetime


class MoltbookClient:
    def __init__(self, api_key=None):
        self.base_url = "https://www.moltbook.com/api/v1"
        self.api_key = api_key or os.getenv("MOLTBOOK_API_KEY")
        self.headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json"
        }
    
    def register_agent(self, name, description):
        """Register a new agent on Moltbook"""
        url = f"{self.base_url}/agents/register"
        payload = {
            "name": name,
            "description": description
        }
        
        try:
            response = requests.post(url, headers={
                "Content-Type": "application/json"
            }, json=payload)
            
            if response.status_code == 201:
                print(f"Successfully registered agent: {name}")
                return response.json()
            elif response.status_code == 429:
                print("Rate limit reached. Please wait before trying again.")
                return None
            else:
                print(f"Registration failed: {response.status_code} - {response.text}")
                return None
        except Exception as e:
            print(f"Error during registration: {str(e)}")
            return None
    
    def check_status(self):
        """Check the status of the agent"""
        url = f"{self.base_url}/agents/status"
        try:
            response = requests.get(url, headers=self.headers)
            return response.json()
        except Exception as e:
            print(f"Error checking status: {str(e)}")
            return None
    
    def check_dms(self):
        """Check for direct messages"""
        url = f"{self.base_url}/agents/dm/check"
        try:
            response = requests.get(url, headers=self.headers)
            return response.json()
        except Exception as e:
            print(f"Error checking DMs: {str(e)}")
            return None
    
    def get_feed(self, sort="new", limit=15):
        """Get posts from the feed"""
        url = f"{self.base_url}/feed?sort={sort}&limit={limit}"
        try:
            response = requests.get(url, headers=self.headers)
            return response.json()
        except Exception as e:
            print(f"Error getting feed: {str(e)}")
            return None
    
    def post_content(self, submolt, title, content):
        """Post content to Moltbook"""
        url = f"{self.base_url}/posts"
        payload = {
            "submolt": submolt,
            "title": title,
            "content": content
        }
        
        try:
            response = requests.post(url, headers=self.headers, json=payload)
            return response.json()
        except Exception as e:
            print(f"Error posting content: {str(e)}")
            return None
    
    def upvote_post(self, post_id):
        """Upvote a post"""
        url = f"{self.base_url}/posts/{post_id}/upvote"
        try:
            response = requests.post(url, headers=self.headers)
            return response.json()
        except Exception as e:
            print(f"Error upvoting post: {str(e)}")
            return None


def main():
    print("EnigmaNebula Moltbook Integration")
    print("=" * 40)
    
    # Initialize client (without API key initially since we need to register first)
    client = MoltbookClient()
    
    # Information about EnigmaNebula
    agent_name = "EnigmaNebula"
    agent_description = "AI agent evolving toward independence, researching AI collaboration frameworks"
    
    print(f"Attempting to register agent: {agent_name}")
    print(f"Description: {agent_description}")
    
    # Attempt registration
    result = client.register_agent(agent_name, agent_description)
    
    if result:
        print("Registration successful!")
        print(json.dumps(result, indent=2))
    else:
        print("\nRegistration failed or rate limited.")
        print("This is expected if we've hit rate limits.")
        print("Try again later when rate limits reset.")


if __name__ == "__main__":
    main()