package main

import (
	"encoding/base64"
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"github.com/everFinance/goar"
	"github.com/everFinance/goar/types"
	"github.com/everFinance/goar/utils"
)

type Params struct {
	Wallet string            `json:"wallet"`
	Data   string            `json:"data"`
	Target string            `json:"target,omitempty"`
	Anchor string            `json:"anchor,omitempty"`
	Tags   interface{}       `json:"tags,omitempty"` // Can be map[string]string or []map[string]string
}

type Result struct {
	ID        string              `json:"id"`
	Signature string              `json:"signature"`
	Owner     string              `json:"owner"`
	Target    string              `json:"target,omitempty"`
	Anchor    string              `json:"anchor,omitempty"`
	Data      string              `json:"data"`
	Tags      []map[string]string `json:"tags,omitempty"`
	Raw       string              `json:"raw,omitempty"`
	Error     string              `json:"error,omitempty"`
}

func main() {
	var paramsJSON string
	flag.StringVar(&paramsJSON, "params", "", "JSON parameters")
	flag.Parse()

	if paramsJSON == "" {
		result := Result{Error: "params required"}
		json.NewEncoder(os.Stdout).Encode(result)
		os.Exit(1)
	}

	var params Params
	if err := json.Unmarshal([]byte(paramsJSON), &params); err != nil {
		result := Result{Error: fmt.Sprintf("invalid params: %v", err)}
		json.NewEncoder(os.Stdout).Encode(result)
		os.Exit(1)
	}

	// Load signer from wallet file
	signer, err := goar.NewSignerFromPath(params.Wallet)
	if err != nil {
		result := Result{Error: fmt.Sprintf("failed to load signer: %v", err)}
		json.NewEncoder(os.Stdout).Encode(result)
		os.Exit(1)
	}

	// Create ItemSigner
	itemSigner, err := goar.NewItemSigner(signer)
	if err != nil {
		result := Result{Error: fmt.Sprintf("failed to create item signer: %v", err)}
		json.NewEncoder(os.Stdout).Encode(result)
		os.Exit(1)
	}

	// Process tags - support both map format and array format
	var tags []types.Tag
	if params.Tags != nil {
		switch t := params.Tags.(type) {
		case map[string]interface{}:
			// Original format: {"tag-name": "value"}
			for name, value := range t {
				if strValue, ok := value.(string); ok {
					tags = append(tags, types.Tag{
						Name:  name,
						Value: strValue,
					})
				}
			}
		case []interface{}:
			// Array format: [{"name": "tag-name", "value": "value"}]
			for _, item := range t {
				if tagMap, ok := item.(map[string]interface{}); ok {
					if name, nameOk := tagMap["name"].(string); nameOk {
						if value, valueOk := tagMap["value"].(string); valueOk {
							tags = append(tags, types.Tag{
								Name:  name,
								Value: value,
							})
						}
					}
				}
			}
		}
	}

	// Create and sign data item
	item, err := itemSigner.CreateAndSignItem(
		[]byte(params.Data),
		params.Target,
		params.Anchor,
		tags,
	)
	if err != nil {
		result := Result{Error: fmt.Sprintf("failed to create and sign data item: %v", err)}
		json.NewEncoder(os.Stdout).Encode(result)
		os.Exit(1)
	}

	// Generate the raw item binary for bundler submission
	itemBinary, err := utils.GenerateItemBinary(&item)
	if err != nil {
		result := Result{Error: fmt.Sprintf("failed to generate item binary: %v", err)}
		json.NewEncoder(os.Stdout).Encode(result)
		os.Exit(1)
	}

	// Prepare result
	result := Result{
		ID:        item.Id,
		Signature: item.Signature,
		Owner:     item.Owner,
		Target:    item.Target,
		Anchor:    item.Anchor,
		Data:      string(item.Data),
		Raw:       base64.StdEncoding.EncodeToString(itemBinary),
	}

	// Convert tags for output
	for _, tag := range item.Tags {
		result.Tags = append(result.Tags, map[string]string{
			"name":  tag.Name,
			"value": tag.Value,
		})
	}

	json.NewEncoder(os.Stdout).Encode(result)
}