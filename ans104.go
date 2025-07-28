package main

import (
	"fmt"
	"github.com/everFinance/goar"
	"github.com/everFinance/goar/types"
	"github.com/everFinance/goar/utils"
)

// Plugin exports the functions available to Lua
type Plugin struct{}

// CreateDataItem creates and signs an ANS-104 data item
func (p *Plugin) CreateDataItem(params map[string]interface{}) (map[string]interface{}, error) {
	// Extract parameters
	walletPath, ok := params["wallet"].(string)
	if !ok {
		return nil, fmt.Errorf("wallet path is required")
	}
	
	data, ok := params["data"].(string)
	if !ok {
		return nil, fmt.Errorf("data is required")
	}
	
	// Optional parameters
	target, _ := params["target"].(string)
	anchor, _ := params["anchor"].(string)
	
	// Load signer from wallet file
	signer, err := goar.NewSignerFromPath(walletPath)
	if err != nil {
		return nil, fmt.Errorf("failed to load signer: %w", err)
	}
	
	// Create ItemSigner
	itemSigner, err := goar.NewItemSigner(signer)
	if err != nil {
		return nil, fmt.Errorf("failed to create item signer: %w", err)
	}
	
	// Process tags
	var tags []types.Tag
	if tagsParam, ok := params["tags"].(map[string]interface{}); ok {
		for name, value := range tagsParam {
			if strValue, ok := value.(string); ok {
				tags = append(tags, types.Tag{
					Name:  name,
					Value: strValue,
				})
			}
		}
	}
	
	// Create and sign data item
	item, err := itemSigner.CreateAndSignItem(
		[]byte(data),
		target,
		anchor,
		tags,
	)
	if err != nil {
		return nil, fmt.Errorf("failed to create and sign data item: %w", err)
	}
	
	// Generate the raw item binary for bundler submission
	itemBinary, err := utils.GenerateItemBinary(&item)
	if err != nil {
		return nil, fmt.Errorf("failed to generate item binary: %w", err)
	}
	
	// Return result
	result := map[string]interface{}{
		"id":        item.Id,
		"signature": item.Signature,
		"owner":     item.Owner,
		"target":    item.Target,
		"anchor":    item.Anchor,
		"data":      string(item.Data),
		"raw":       itemBinary,  // Raw data item binary for bundler submission
	}
	
	// Convert tags for output
	var outputTags []map[string]string
	for _, tag := range item.Tags {
		outputTags = append(outputTags, map[string]string{
			"name":  tag.Name,
			"value": tag.Value,
		})
	}
	result["tags"] = outputTags
	
	return result, nil
}

// SignDataItem signs an existing data item
func (p *Plugin) SignDataItem(params map[string]interface{}) (map[string]interface{}, error) {
	// For now, we'll create a new signed item since goar doesn't expose a direct sign method
	// In practice, you would need the unsigned item's data and recreate it
	return nil, fmt.Errorf("signing existing items not currently supported - use CreateDataItem instead")
}

// GetBundle creates a data item and returns it either as a raw data item or wrapped in a bundle
func (p *Plugin) GetBundle(params map[string]interface{}) (map[string]interface{}, error) {
	// Extract parameters
	walletPath, ok := params["wallet"].(string)
	if !ok {
		return nil, fmt.Errorf("wallet path is required")
	}
	
	data, ok := params["data"].(string)
	if !ok {
		return nil, fmt.Errorf("data is required")
	}
	
	// Optional parameters
	target, _ := params["target"].(string)
	anchor, _ := params["anchor"].(string)
	
	// Load signer from wallet file
	signer, err := goar.NewSignerFromPath(walletPath)
	if err != nil {
		return nil, fmt.Errorf("failed to load signer: %w", err)
	}
	
	// Create ItemSigner
	itemSigner, err := goar.NewItemSigner(signer)
	if err != nil {
		return nil, fmt.Errorf("failed to create item signer: %w", err)
	}
	
	// Process tags
	var tags []types.Tag
	if tagsParam, ok := params["tags"].(map[string]interface{}); ok {
		for name, value := range tagsParam {
			if strValue, ok := value.(string); ok {
				tags = append(tags, types.Tag{
					Name:  name,
					Value: strValue,
				})
			}
		}
	}
	
	// Create and sign data item
	item, err := itemSigner.CreateAndSignItem(
		[]byte(data),
		target,
		anchor,
		tags,
	)
	if err != nil {
		return nil, fmt.Errorf("failed to create and sign data item: %w", err)
	}
	
	// Generate the raw item binary for bundler submission
	itemBinary, err := utils.GenerateItemBinary(&item)
	if err != nil {
		return nil, fmt.Errorf("failed to generate item binary: %w", err)
	}
	
	// Also create bundle if needed
	bundle, err := utils.NewBundle(item)
	if err != nil {
		return nil, fmt.Errorf("failed to create bundle: %w", err)
	}
	
	// Return both raw data item and bundle data
	return map[string]interface{}{
		"raw":    itemBinary,           // Raw data item binary for bundler submission
		"bundle": bundle.BundleBinary,  // Bundle binary (for direct Arweave submission)
		"items": []map[string]interface{}{
			{
				"id":        item.Id,
				"signature": item.Signature,
				"owner":     item.Owner,
				"target":    item.Target,
				"anchor":    item.Anchor,
				"data":      string(item.Data),
			},
		},
		"version": "2.0.0",
	}, nil
}

// GetPlugin returns the plugin instance (required by Hype)
func GetPlugin() interface{} {
	return &Plugin{}
}