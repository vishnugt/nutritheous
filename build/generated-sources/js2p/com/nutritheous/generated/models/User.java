
package com.nutritheous.generated.models;

import java.util.UUID;
import javax.annotation.processing.Generated;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyDescription;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;


/**
 * User
 * <p>
 * User account information
 * 
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonPropertyOrder({
    "userId",
    "email",
    "token",
    "role"
})
@Generated("jsonschema2pojo")
public class User {

    /**
     * Unique identifier for the user
     * (Required)
     * 
     */
    @JsonProperty("userId")
    @JsonPropertyDescription("Unique identifier for the user")
    private UUID userId;
    /**
     * User's email address
     * (Required)
     * 
     */
    @JsonProperty("email")
    @JsonPropertyDescription("User's email address")
    private String email;
    /**
     * JWT authentication token
     * 
     */
    @JsonProperty("token")
    @JsonPropertyDescription("JWT authentication token")
    private String token;
    /**
     * User role (e.g., USER, ADMIN)
     * 
     */
    @JsonProperty("role")
    @JsonPropertyDescription("User role (e.g., USER, ADMIN)")
    private String role;

    /**
     * No args constructor for use in serialization
     * 
     */
    public User() {
    }

    /**
     * 
     * @param role
     *     User role (e.g., USER, ADMIN).
     * @param userId
     *     Unique identifier for the user.
     * @param email
     *     User's email address.
     * @param token
     *     JWT authentication token.
     */
    public User(UUID userId, String email, String token, String role) {
        super();
        this.userId = userId;
        this.email = email;
        this.token = token;
        this.role = role;
    }

    /**
     * Unique identifier for the user
     * (Required)
     * 
     */
    @JsonProperty("userId")
    public UUID getUserId() {
        return userId;
    }

    /**
     * Unique identifier for the user
     * (Required)
     * 
     */
    @JsonProperty("userId")
    public void setUserId(UUID userId) {
        this.userId = userId;
    }

    public User withUserId(UUID userId) {
        this.userId = userId;
        return this;
    }

    /**
     * User's email address
     * (Required)
     * 
     */
    @JsonProperty("email")
    public String getEmail() {
        return email;
    }

    /**
     * User's email address
     * (Required)
     * 
     */
    @JsonProperty("email")
    public void setEmail(String email) {
        this.email = email;
    }

    public User withEmail(String email) {
        this.email = email;
        return this;
    }

    /**
     * JWT authentication token
     * 
     */
    @JsonProperty("token")
    public String getToken() {
        return token;
    }

    /**
     * JWT authentication token
     * 
     */
    @JsonProperty("token")
    public void setToken(String token) {
        this.token = token;
    }

    public User withToken(String token) {
        this.token = token;
        return this;
    }

    /**
     * User role (e.g., USER, ADMIN)
     * 
     */
    @JsonProperty("role")
    public String getRole() {
        return role;
    }

    /**
     * User role (e.g., USER, ADMIN)
     * 
     */
    @JsonProperty("role")
    public void setRole(String role) {
        this.role = role;
    }

    public User withRole(String role) {
        this.role = role;
        return this;
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(User.class.getName()).append('@').append(Integer.toHexString(System.identityHashCode(this))).append('[');
        sb.append("userId");
        sb.append('=');
        sb.append(((this.userId == null)?"<null>":this.userId));
        sb.append(',');
        sb.append("email");
        sb.append('=');
        sb.append(((this.email == null)?"<null>":this.email));
        sb.append(',');
        sb.append("token");
        sb.append('=');
        sb.append(((this.token == null)?"<null>":this.token));
        sb.append(',');
        sb.append("role");
        sb.append('=');
        sb.append(((this.role == null)?"<null>":this.role));
        sb.append(',');
        if (sb.charAt((sb.length()- 1)) == ',') {
            sb.setCharAt((sb.length()- 1), ']');
        } else {
            sb.append(']');
        }
        return sb.toString();
    }

    @Override
    public int hashCode() {
        int result = 1;
        result = ((result* 31)+((this.role == null)? 0 :this.role.hashCode()));
        result = ((result* 31)+((this.userId == null)? 0 :this.userId.hashCode()));
        result = ((result* 31)+((this.email == null)? 0 :this.email.hashCode()));
        result = ((result* 31)+((this.token == null)? 0 :this.token.hashCode()));
        return result;
    }

    @Override
    public boolean equals(Object other) {
        if (other == this) {
            return true;
        }
        if ((other instanceof User) == false) {
            return false;
        }
        User rhs = ((User) other);
        return (((((this.role == rhs.role)||((this.role!= null)&&this.role.equals(rhs.role)))&&((this.userId == rhs.userId)||((this.userId!= null)&&this.userId.equals(rhs.userId))))&&((this.email == rhs.email)||((this.email!= null)&&this.email.equals(rhs.email))))&&((this.token == rhs.token)||((this.token!= null)&&this.token.equals(rhs.token))));
    }

}
